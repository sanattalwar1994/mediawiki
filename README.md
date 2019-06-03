# DOCKER FILES
media-dockerfile && sql-dockerfile are respective dockerfiles for application

# Terraform script to create ELB and autoscaling group that is based on launch template which has all components of docker and k8s installed
media.tf

# Kubernetes service and deployment files which help in orchestarting the application across different nodes.
service.yml
deployment.yml
