# spigot-plugin-deb-packer

Deploys a Cloudformation stack containing:

- Input S3 bucket
- Output S3 bucket (APT repository)
- Step function that triggers when files are uploaded into S3
- Codebuild project that pulls the jarfile from S3, builds into DEV and publishes to the APT repository

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

Deploy as a cloudformation stack and pass the parameter to a public link to the source github repository (change it if you fork, see the template file)

```
aws cloudformation create-stack --stack-name spigot-plugin-deb-packer --template-body file://template.yaml --capabilities CAPABILITY_IAM
```

# Development

To test the buildspec file:

1. Download and build the ubuntu codebuild image (takes 20+mins)

```
git clone https://github.com/aws/aws-codebuild-docker-images.git
cd aws-codebuild-docker-images/ubuntu/standard/5.0
docker build -t aws/codebuild/standard:5.0 .
```

2. Download the codebuild agent

```
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker pull public.ecr.aws/codebuild/local-builds:latest
wget https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh
chmod +x codebuild_build.sh
```

4. Create two s3 buckets, one for input and one for output
5. Upload some sample jarfiles into the input bucket and label which bucket is which in the test.env file 
6. `./codebuild_build.sh -i aws/codebuild/standard:5.0 -a out -e test.env -c`