FROM hashicorp/terraform:1.9.5
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
RUN terraform init
COPY *.py $APP_DIR/
COPY *.yaml $APP_DIR/
COPY static/ $APP_DIR/static/
COPY templates/ $APP_DIR/templates/
COPY id_* /root/.ssh/
ENTRYPOINT gunicorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' app:app
EXPOSE $PORT/tcp
