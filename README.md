[README_updated.md](https://github.com/user-attachments/files/30786284/README_updated.md)
# Resilient Container Platform & CI/CD

## Project Overview

This project modernizes a mission-critical e-commerce platform using a **resilient, containerized architecture on AWS**. The solution demonstrates high availability, asynchronous processing, managed caching, automated disaster recovery, observability, and infrastructure automation.

The platform is deployed on **Amazon ECS Fargate across multiple Availability Zones**, uses **Amazon SQS for decoupled processing**, **ElastiCache Redis for performance**, and includes a documented **disaster recovery and failover strategy**.

---

## Architecture Diagram

The architecture diagram is stored in `docs/architecture.png`.

```text
Route 53
   |
   v
Application Load Balancer
   |
   v
ECS Fargate Web Service (2 AZs)
   |
   +--> ElastiCache Redis
   |
   +--> Amazon SQS
            |
            v
      ECS Worker Service
```

---

## Architecture Summary

- **Route 53:** Primary to ALB, failover to S3 maintenance page
- **Application Load Balancer:** Distributes traffic across two Availability Zones
- **ECS Fargate Web Service:** Stateless frontend tasks with rolling deployments
- **ElastiCache Redis:** Shared managed cache for frequent reads
- **Amazon SQS:** Buffers asynchronous order-processing jobs
- **ECS Fargate Worker Service:** Consumes SQS messages and scales independently
- **CloudWatch:** Metrics, alarms, logs, and scaling visibility
- **AWS Backup:** Automated daily backup policy and retention
- **ECR / CodeBuild / CodePipeline:** Container image delivery and deployment automation design

---

## Implemented Components

### Compute Layer

- Amazon ECS (Fargate)
- Multi-AZ deployment
- Application Load Balancer
- Rolling deployments

### Caching Layer

- Amazon ElastiCache Redis
- Shared cache across ECS tasks
- Reduced application database load

### Asynchronous Processing

- Amazon SQS queue
- Dedicated worker service
- Decoupled order processing

### Scaling

- Web service target tracking auto scaling
- Worker service auto scaling configuration
- Independent scaling of frontend and backend

### Disaster Recovery

- AWS Backup plan
- S3 static maintenance page
- Route 53 failover design documented

### Observability

- CloudWatch metrics
- ECS service metrics
- SQS metrics
- Worker application logs

---

## Repository Structure

```text
app/
├── web/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
└── worker/
    ├── worker.py
    ├── requirements.txt
    └── Dockerfile

pipeline/

infrastructure/
├── network-ecs.yml
├── ecs-web.yml
├── web-autoscaling.yml
├── redis.yml
├── ecs-worker.yml
├── worker-autoscaling.yml
└── backup.yml

docs/
README.md
```

---

## Deployment Evidence

### ECS Services

- Web service running across **two Availability Zones**
- Worker service running in private subnets
- Health checks passing

### Application Load Balancer

- Internet-facing ALB
- Target group health checks on `/health`
- Traffic distributed across multiple tasks

### Managed Redis Cache

- Redis cluster successfully deployed
- ECS web service configured to use managed Redis endpoint

### SQS Worker Processing

Example worker log output:

```text
Worker started
Processing: order-1
Processing: order-2
Processing: order-3
```

This demonstrates successful **asynchronous message processing**.

---

## CI/CD

Container images are built and stored in **Amazon ECR**. Infrastructure and services are deployed using **CloudFormation**, enabling repeatable and automated environments.

---

## Scaling

- Web service scales between **2 and 6 tasks**
- Worker service scales independently
- Queue depth and ECS metrics are visible in CloudWatch

---

## Disaster Recovery & Backup

### AWS Backup

- Daily backup schedule
- Dedicated backup vault
- 7-day retention policy

### Failover Page

S3 static website endpoint is used as the **secondary failover target**.

---

## Route 53 Failover Design

### Primary

```text
ALB → ECS Fargate
```

### Health Check

```text
GET /health
```

### Secondary

```text
S3 maintenance page
```

### Simulated Failure

- Scale ECS service to **0 tasks** (or stop all tasks)
- ALB becomes unhealthy
- Route 53 redirects traffic to the S3 maintenance page

This provides **graceful degradation during an outage**.

---

## Security & Networking

- Private subnets for ECS tasks and Redis
- Public subnets only for the ALB
- Security group isolation between tiers
- No public IPs assigned to application tasks

---

## Key AWS Services Used

- Amazon ECS Fargate
- Application Load Balancer
- Amazon ElastiCache Redis
- Amazon SQS
- Amazon CloudWatch
- AWS Backup
- Amazon S3
- Amazon Route 53
- Amazon ECR
- AWS CodeBuild
- AWS CodePipeline
- AWS CloudFormation

---

## Learning Outcomes

Through this capstone I was able to:

- Design a **highly available container platform**
- Implement **multi-AZ networking**
- Use **managed Redis caching**
- Decouple processing with **Amazon SQS**
- Configure **ECS auto scaling**
- Implement **backup and failover strategies**
- Automate infrastructure with **CloudFormation**
- Monitor services using **CloudWatch**

---

## Cleanup

To avoid ongoing AWS charges:

```bash
aws cloudformation delete-stack --stack-name resilient-worker-autoscaling --region us-east-1
aws cloudformation delete-stack --stack-name resilient-worker-service --region us-east-1
aws cloudformation delete-stack --stack-name resilient-web-autoscaling --region us-east-1
aws cloudformation delete-stack --stack-name resilient-web-service --region us-east-1
aws cloudformation delete-stack --stack-name resilient-redis --region us-east-1
aws cloudformation delete-stack --stack-name resilient-backup --region us-east-1
aws cloudformation delete-stack --stack-name resilient-platform-network --region us-east-1
```

---

## Final Repository

**GitHub:** https://github.com/Leon-Mwai/resilient-container-platform

---

## Project Status

**Complete**

Resilient Container Platform with Multi-AZ ECS, Redis caching, SQS workers, auto scaling, backup, failover design, and CloudFormation infrastructure automation.
