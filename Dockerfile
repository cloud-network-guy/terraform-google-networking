FROM hashicorp/terraform:latest
WORKDIR /tmp
RUN apk add --no-cache bash git make python3 py3-pip
COPY ./pyproject.toml ./
RUN pip install --upgrade pip --break-system-packages
RUN pip install --break-system-packages
ENV APP_DIR=/tmp
COPY terraform.tf $APP_DIR/
ENV PORT=8080
ENV GOOGLE_APPLICATION_CREDENTIALS="application_default_credentials.json"
ENV TF_WORKSPACE="default"
ENV TF_CLI_ARGS="-var-file=terraform.tfvars"
ENV WSGI_APP=wsgi:app
ENV APP_APP=app:app
RUN terraform init
COPY *.py $APP_DIR/
COPY *.yaml $APP_DIR/
COPY templates/ $APP_DIR/templates/
COPY id_* /root/.ssh/
ENTRYPOINT cd $APP_DIR && gunicorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' $WSGI_APP
#ENTRYPOINT cd $APP_DIR && hypercorn -b 0.0.0.0:$PORT -w 1 --access-logfile '-' $APP_APP
EXPOSE $PORT/tcp
