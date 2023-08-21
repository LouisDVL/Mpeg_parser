# Mpeg_parser

## Requirements

- aws cli [AWS configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- required permissions
  - S3 Buckets
  - cloudwatch
  - kinesis
  - lambda
  - CloudFormation
  - OpenSearch

## To deploy

- first run in command line `./build.sh`
- second run in command line `./deploy_all.sh`

## To destroy

- run in command line `./destroy_all.sh`
