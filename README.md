# terraform-state-file-in-s3
Managing your Terraform state file in an S3 bucket is a common and recommended practice, especially when working in a team or dealing with larger, more complex infrastructures. This example shows how to configure terraform to store the state file in ionos s3

You should also need to consider the following S3 bucket configuration possibilities
- Security and Access Control - who has access to the state and who can change it?
- Audit Trail / Logging - who has made any changes to the infrastructure?
- Versioning - optionally turn on S3 object versioning to store the past states
