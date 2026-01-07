#FROM alpine:latest
FROM hashicorp/terraform:latest
WORKDIR /tmp
RUN apk add --no-cache bash git make python3 py3-pip openssh-client
COPY ./pyproject.toml ./
RUN pip install --upgrade pip --break-system-packages
RUN pip install --break-system-packages .
ENV APP_DIR=/tmp
COPY terraform.tf $APP_DIR/
ENV PORT=8080
#ENV GOOGLE_APPLICATION_CREDENTIALS="application_default_credentials.json"
ENV TF_WORKSPACE="default"
ENV TF_CLI_ARGS="-var-file=terraform.tfvars"
ENV WSGI_APP=wsgi:app
ENV APP_APP=app:app
RUN terraform init
COPY *.py $APP_DIR/
COPY *.yaml $APP_DIR/
COPY fields.toml $APP_DIR/
COPY templates/ $APP_DIR/templates/
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY id_* /root/.ssh/
CMD chmod 600 /root/.ssh/id_*
#CMD ["pip","list"]
ENTRYPOINT cd $APP_DIR && hypercorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' $APP_APP
EXPOSE $PORT/tcp
