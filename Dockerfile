FROM hashicorp/terraform:1.9.5
RUN apk add --no-cache bash curl git make python3
RUN mkdir /opt/terraform
WORKDIR /opt/terraform/
COPY *.tf /opt/terraform/
COPY *.tfvars /opt/terraform/
COPY *.json /opt/terraform/
ENV PORT=8080
ENV GOOGLE_APPLICATION_CREDENTIALS="application_default_credentials.json"
ENV TF_WORKSPACE="default"
ENV TF_CLI_ARGS="-var-file=terraform.tfvars"
RUN terraform init
CMD ["pip", "list"]
#ENTRYPOINT gunicorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' wsgi:app
EXPOSE $PORT/tcp
