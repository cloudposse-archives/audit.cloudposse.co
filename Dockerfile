FROM cloudposse/terraform-root-modules:0.4.5 as terraform-root-modules

FROM cloudposse/geodesic:0.11.6

ENV DOCKER_IMAGE "cpco/audit.cloudposse.co"
ENV DOCKER_TAG "latest"

ENV BANNER audit.cloudposse.co

# Default AWS Profile name
ENV AWS_DEFAULT_PROFILE="cpco-audit-admin"

# Parent DNS zone for the cluster
ENV CLUSTER_NAME="audit.cloudposse.co"

# AWS Region for the cluster
ENV AWS_REGION="us-west-2"

# Terraform State Bucket
ENV TF_BUCKET="cpco-audit-terraform-state"
ENV TF_BUCKET_REGION="us-west-2"
ENV TF_DYNAMODB_TABLE="cpco-audit-terraform-state-lock"

# chamber KMS config
ENV CHAMBER_KMS_KEY_ALIAS="alias/cpco-audit-chamber"

# Copy root modules
COPY --from=terraform-root-modules /aws/ /conf/

# Place configuration in 'conf/' directory
COPY conf/ /conf/

# Filesystem entry for tfstate
RUN s3 fstab '${TF_BUCKET}' '/' '/secrets/tf'

WORKDIR /conf/
