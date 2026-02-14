# cloud backup automation

## simple database cloud backup

for different setups i'M likely to be using

- runtime/compute
  - linux VM
    - provisionned within that cloud vendor
    - agnostic: linked to cloud via public internet
  - serverless function (glue)
    - aws lambda
    - azure function app
- database
  - sqlite
  - aws dynamodb
- public cloud blob storage:
  - aws S3
  - azure storage account
