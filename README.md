# spigot-plugin-deb-packer

Deploys a Cloudformation stack containing:

- Input S3 bucket
- Output S3 bucket (APT repository)
- ECR repository containing the debpacker
- ECS Task Definition to run the debpacker

# Usage notes

The codebuild project uses JAR_S3_BUCKET and JAR_S3_KEY to find the input jarfile.

Plugin names will be converted to lowercase as per debian rules.

Version identifiers with + symbols are replaced with a period (.) .

To use the repository, append the following line to `/etc/apt/sources.list`:

```
deb [arch=all trusted=yes] http://$BUCKET_NAME.s3-$BUCKET_REGION.amazonaws.com spigot-plugins main
```

Installed jars will be saved to `/opt/spigot-plugins`.

# Deployment

Deploy as a cloudformation stack and pass the parameter of the subnets that the ECS tasks will launch in.

```
export WORKER_SUBNETS=subnet-111,subnet-222,subnet-333
aws cloudformation update-stack --stack-name spigot-deb-s3-packer --template-body file://template.yaml --capabilities CAPABILITY_IAM --parameters ParameterKey=WorkerSubnets,ParameterValue=\'$WORKER_SUBNETS'
```

Before you upload anything, make sure you build and push the image to the ECR repository created by the CloudFormation stack!