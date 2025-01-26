#FROM python:3.12-alpine
FROM hashicorp/terraform:1.9.8
WORKDIR /tmp
RUN apk add --no-cache bash git make python3 py3-pip
COPY ./requirements.txt ./
RUN pip install --upgrade pip --break-system-packages
RUN pip install -r requirements.txt --break-system-packages
COPY terraform.tf $APP_DIR/
ENV PORT=8080
ENV APP_DIR=/tmp
ENV GOOGLE_APPLICATION_CREDENTIALS="application_default_credentials.json"
ENV TF_WORKSPACE="default"
ENV TF_CLI_ARGS="-var-file=terraform.tfvars"
ENV WSGI_APP=wsgi:app
RUN terraform init
COPY *.py $APP_DIR/
COPY *.yaml $APP_DIR/
#COPY static/ $APP_DIR/static/
COPY templates/ $APP_DIR/templates/
COPY id_* /root/.ssh/
#CMD ["pip", "list"]
ENTRYPOINT cd $APP_DIR && gunicorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' $WSGI_APP
EXPOSE $PORT/tcp
