# Lambda function to delete Available EBS Volumes

This lambda function will delete EBS volumes whose status is "Available", unless there is an associated Kubernetes PersistentVolume, in an EKS cluster, with the Phase "Bound" or "Released". Kubernetes PersistentVolumes may exist for Kubernetes CronJobs that are not actively running, or for applications that were deployed to the cluster and subsequently removed. To ensure volumes get cleaned up, unused PersistentVolumes should either be deleted or marked available (by removing the `claimRef` from the `spec`).

This function will run every day at 11 PM Hawaii time (5 AM EST).

### Avoid Deletion of EBS Volumes

To avoid deletion of an EBS Volume, please create the following Tag.

Key : DELETE
Value : NO

Note - "DELETE" is case-sensitive.
