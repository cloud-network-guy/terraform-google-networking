PROJECT_ID := my-project
REPO := my-repo
SERVICE := terraform-google-networking
HOST := us-docker.pkg.dev
REGION := us-central1

include Makefile.env

all: gcp-setup cloud-build cloud-run-deploy

gcp-setup:
	gcloud config set project $(PROJECT_ID)

cloud-build:
	#gcloud auth configure-docker $(HOST)
	gcloud builds submit --tag $(HOST)/$(PROJECT_ID)/$(REPO)/$(SERVICE):latest .


cloud-run-deploy:
	gcloud config set run/region $(REGION)
	gcloud run deploy $(SERVICE) --image $(HOST)/$(PROJECT_ID)/$(REPO)/$(SERVICE):latest
