FROM cloudposse/terraform-root-modules:0.5.3 as terraform-root-modules

FROM cloudposse/geodesic:0.39.0

ENV DOCKER_IMAGE="cloudposse/audit.cloudposse.co"
ENV DOCKER_TAG="latest"

# Geodesic banner
ENV BANNER="audit.cloudposse.co"

# AWS Region
ENV AWS_REGION="us-west-2"

# Terraform vars
ENV TF_VAR_region="${AWS_REGION}"
ENV TF_VAR_account_id="205035139483"
ENV TF_VAR_namespace="cpco"
ENV TF_VAR_stage="audit"
ENV TF_VAR_domain_name="audit.cloudposse.co"
ENV TF_VAR_zone_name="audit.cloudposse.co."

# chamber KMS config
ENV CHAMBER_KMS_KEY_ALIAS="alias/${TF_VAR_namespace}-${TF_VAR_stage}-chamber"

# Terraform State Bucket
ENV TF_BUCKET_REGION="${AWS_REGION}"
ENV TF_BUCKET="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state"
ENV TF_DYNAMODB_TABLE="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state-lock"

# Default AWS Profile name
ENV AWS_DEFAULT_PROFILE="${TF_VAR_namespace}-${TF_VAR_stage}-admin"

# Copy root modules
COPY --from=terraform-root-modules /aws/tfstate-backend/ /conf/tfstate-backend/
COPY --from=terraform-root-modules /aws/account-dns/ /conf/account-dns/
COPY --from=terraform-root-modules /aws/acm/ /conf/acm/
COPY --from=terraform-root-modules /aws/chamber/ /conf/chamber/
COPY --from=terraform-root-modules /aws/audit-cloudtrail/ /conf/audit-cloudtrail/

# Place configuration in 'conf/' directory
COPY conf/ /conf/

# Filesystem entry for tfstate
RUN s3 fstab '${TF_BUCKET}' '/' '/secrets/tf'

WORKDIR /conf/
