import boto3
ec2 = boto3.resource('ec2',region_name='us-east-1')
def lambda_handler(event, context):
    for vol in ec2.volumes.all():
        if  vol.state=='available':
            if vol.tags is None:
                vid=vol.id
                v=ec2.Volume(vol.id)
                v.delete()
                print ('No tags found. Deleteing the below Available volume' +vid)
                continue
            tags = {}
            for tag in vol.tags:
                tags[tag['Key']] = tag['Value']
            if not 'DELETE' in tags :
                vid=vol.id
                v=ec2.Volume(vol.id)
                v.delete()
                print ('DELETE tag not found. Deleteing Available volume' +vid)
            elif tags['DELETE'] not in ['NO','No','no'] and vol.state=='available':
                vid=vol.id
                v=ec2.Volume(vol.id)
                v.delete()
                print ('DELETE tag found and value not equal to NO. Deleteing Available volume' +vid)
