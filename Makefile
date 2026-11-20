PROJECT_ID := my-project
REPO := cloudbuild
HOST := us-docker.pkg.dev
REGION := us-central1
SERVICE := terraform-google-networking
TAG := latest

include Makefile.env

all: gcp-setup cloud-build cloud-run-deploy

gcp-setup:
	gcloud config set project $(PROJECT_ID)

cloud-build:
	gcloud builds submit --tag $(HOST)/$(PROJECT_ID)/$(REPO)/$(SERVICE):$(TAG) .

cloud-run-deploy:
	gcloud config set run/region $(REGION)
	gcloud run deploy $(SERVICE) --image $(HOST)/$(PROJECT_ID)/$(REPO)/$(SERVICE):$(TAG)
