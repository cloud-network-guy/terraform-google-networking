FROM hashicorp/terraform:1.8.5
RUN apk add --no-cache bash curl git make
RUN mkdir /opt/terraform
WORKDIR /opt/terraform/
COPY *.tf /opt/terraform/
COPY *.tfvars /opt/terraform/
COPY *.json /opt/terraform/
ENV GOOGLE_APPLICATION_CREDENTIALS="application_default_credentials.json"
ENV TF_WORKSPACE="default"
ENV TF_CLI_ARGS="-var-file=terraform.tfvars"
RUN terraform init
ENTRYPOINT ["terraform", "plan"]
