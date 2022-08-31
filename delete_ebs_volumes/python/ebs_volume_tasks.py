import base64
import logging
import os
import re
import tempfile

import boto3
from botocore.signers import RequestSigner
import kubernetes.client
from kubernetes.client import ApiException

from kubernetes_helper import PersistentVolumeIterable

logger = logging.getLogger(__name__)
region = os.environ.get('AWS_REGION') or os.environ.get('AWS_DEFAULT_REGION') or 'us-east-1'

session = boto3.session.Session()
sts = session.client('sts', region_name=region)
ec2 = boto3.resource('ec2', region_name=region)
eks = boto3.client('eks', region_name=region)

STS_TOKEN_EXPIRES_IN = 60


def get_bearer_token(cluster_name):
    service_id = sts.meta.service_model.service_id

    signer = RequestSigner(
        service_id,
        region,
        'sts',
        'v4',
        session.get_credentials(),
        session.events
    )

    params = {
        'method': 'GET',
        'url': 'https://sts.{}.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15'.format(region),
        'body': {},
        'headers': {
            'x-k8s-aws-id': cluster_name
        },
        'context': {}
    }

    signed_url = signer.generate_presigned_url(
        params,
        region_name=region,
        expires_in=STS_TOKEN_EXPIRES_IN,
        operation_name=''
    )

    base64_url = base64.urlsafe_b64encode(signed_url.encode('utf-8')).decode('utf-8')

    # remove any base64 encoding padding
    return 'k8s-aws-v1.' + base64_url.rstrip('=')


def save_cluster_certificate(cluster):
    # Saving the CA cert to a temp file (working around the Kubernetes client limitations)
    fp = tempfile.NamedTemporaryFile(delete=False)
    ca_filename = fp.name
    cert = base64.urlsafe_b64decode(cluster['certificateAuthority']['data'].encode('utf-8'))
    fp.write(cert)
    fp.close()
    return ca_filename


VOLUME_URI_REGEX = re.compile(r'^(aws://[^/]*/)?(?P<volume_id>vol-[0-9a-z]+)$')
K8S_CONNECTION_TIMEOUT = 2
K8S_READ_TIMEOUT = 8


def cleanup(dry_run=False):
    cluster_iterator = eks.get_paginator('list_clusters').paginate()
    bound_volumes = set()
    unbound_volumes = {}
    for cluster_page in cluster_iterator:
        for cluster_name in cluster_page['clusters']:
            try:
                cluster = eks.describe_cluster(name=cluster_name)['cluster']
                conf = kubernetes.client.Configuration()
                conf.retries = 0
                conf.host = cluster['endpoint']
                token = get_bearer_token(cluster_name)
                conf.api_key['authorization'] = token
                conf.api_key_prefix['authorization'] = 'Bearer'
                conf.ssl_ca_cert = save_cluster_certificate(cluster)
                with kubernetes.client.ApiClient(conf) as k8s_client:
                    api_instance = kubernetes.client.CoreV1Api(k8s_client)
                    for volume in PersistentVolumeIterable(api_instance, _request_timeout=(K8S_CONNECTION_TIMEOUT, K8S_READ_TIMEOUT)):
                        match = VOLUME_URI_REGEX.match(volume.spec.aws_elastic_block_store.volume_id)
                        if match is None:
                            raise Exception(
                                'Volume URI is not in the expected format: {}'
                                .format(volume.spec.aws_elastic_block_store.volume_id)
                            )
                        vid = match.group('volume_id')
                        if volume.status.phase in ['Bound', 'Released']:
                            bound_volumes.add(vid)
                        else:
                            unbound_volumes[vid] = (conf, cluster_name, volume)
                logger.info('Successfully processed PersistentVolumes for the cluster "%s"', cluster_name)
            except Exception as err:
                logger.warning(
                    'An error occurred attempting to list PersistentVolumes for the cluster "%s": %s',
                    cluster_name,
                    err
                )

    for vol in ec2.volumes.all():
        if vol.state == 'available':
            vid = vol.id
            if vid in bound_volumes:
                logger.info('Volume is available but associated with an PersistentVolume in EKS ' + vid)
                continue
            deleted = False
            tags = {}
            for tag in (vol.tags or []):
                tags[tag['Key']] = tag['Value']
            if 'DELETE' not in tags:
                v = ec2.Volume(vid)
                deleted = True
                if not dry_run:
                    print('DELETE tag not found. Deleting the Available volume ' + vid)
                    v.delete()
                else:
                    print('[dry_run] DELETE tag not found. Would delete the Available volume ' + vid)
            elif tags['DELETE'] not in ['NO', 'No', 'no'] and vol.state == 'available':
                v = ec2.Volume(vid)
                deleted = True
                if not dry_run:
                    print('DELETE tag found and value not equal to NO. Deleting the Available volume ' + vid)
                    v.delete()
                else:
                    print(
                        '[dry_run] DELETE tag found and value not equal to NO. Would delete the Available volume ' + vid
                    )
            if deleted and vid in unbound_volumes:
                # try to delete the PersistentVolume in EKS as well
                (conf, cluster_name, volume) = unbound_volumes[vid]
                try:
                    if not dry_run:
                        print('Deleting Kubernetes PersistentVolume associated with volume ' + vid)
                        with kubernetes.client.ApiClient(conf) as k8s_client:
                            api_instance = kubernetes.client.CoreV1Api(k8s_client)
                            api_instance.delete_persistent_volume(volume.metadata.name)
                    else:
                        print('[dry_run] Would delete Kubernetes PersistentVolume associated with volume ' + vid)
                except ApiException as err:
                    logger.warning(
                        'Failed to delete PersistentVolume %s from EKS cluster %s: %s',
                        volume.metadata.name,
                        cluster_name,
                        err
                    )
