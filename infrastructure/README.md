# Infrastructure

AWS Infrastructure

- Used AWS Fargate container based hosting
- Used self signed SSL cert inside nginx container
- Redirected all HTTP requests to HTTPS
- Used nginx web server to serve the sttacic content

Enhancements

- Use s3 to store the static web page
- Use Amazon CloudFront as CDN to distribute content globally
- Use ALB for managing SSL certificates via (AWS ACM or self signed certificate) and automatic HTTP-to-HTTPS redirection

## Prerequisites

- Install terraform

```
brew install hashicorp/tap/terraform
```

- Run aws configure

```
aws configure
```

- Set environmental variables

```
export AWS_ACCESS_KEY_ID=<access_key>
export AWS_SECRET_ACCESS_KEY=<secret_key>
export AWS_DEFAULT_REGION=<region>
```

## Execution

- Build Docker image that matches the nginx image platform (arm didn't here as the platforms didn't match)

```bash
docker buildx build --platform linux/amd64 -t webapp-fargate-nginx-image .
```

- Push Docker image

```bash
aws ecr get-login-password --region <aws_region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
docker tag webapp-fargate-nginx-image:latest <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/webapp-fargate-nginx-image:latest
docker push <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/webapp-fargate-nginx-image:latest
```

- Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply
```

### To test my static web application

- copy the ecs task public url

```
https://3.138.32.81/index.html
```

- Destroy the deployment

```bash
terraform destroy
```
