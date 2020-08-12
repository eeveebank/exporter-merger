CURRENT_WORKING_DIR=$(shell pwd)

#------------------------------------------------------------------
# Project build information
#------------------------------------------------------------------
PROJNAME          		:= exporter-merger
VENDOR            		:= eeveebank
MAINTAINER        		:= platform@mettle.co.uk

QUAY_REPO         		:= quay.io/mettle
QUAY_USERNAME     		:= "mettle+exporter_merger"
QUAY_PASSWORD     		?="unknown"

GCR_REPO		  		:= eu.gcr.io/mettle-bank
GCLOUD_SERVICE_KEY		?="unknown"
GCLOUD_SERVICE_EMAIL 	:= circle-ci@mettle-bank.iam.gserviceaccount.com
GOOGLE_PROJECT_ID		:= mettle-bank
GOOGLE_COMPUTE_ZONE		:= europe-west2-a


GCLOUD_SERVICE_KEY_PRIVATE	?="unknown"
GCLOUD_SERVICE_EMAIL_PRIVATE 		:= circle-ci@eevee-bank.iam.gserviceaccount.com
GOOGLE_PROJECT_ID_PRIVATE			:= eevee-bank

CIRCLE_BUILD_NUM  		?="unknown"
VERSION           		:= 2.0.$(CIRCLE_BUILD_NUM)
IMAGE             		:= $(PROJNAME):$(VERSION)


#------------------------------------------------------------------
# CI targets
#------------------------------------------------------------------

build: configure-gcloud-cli-private
	gcloud auth configure-docker --quiet
	docker build \
    --build-arg git_repository=`git config --get remote.origin.url` \
    --build-arg git_branch=`git rev-parse --abbrev-ref HEAD` \
    --build-arg git_commit=`git rev-parse HEAD` \
    --build-arg built_on=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    -t $(IMAGE) .

push-to-quay:
	docker login -u $(QUAY_USERNAME) -p $(QUAY_PASSWORD) quay.io
	docker tag $(IMAGE) $(QUAY_REPO)/$(IMAGE)
	docker push $(QUAY_REPO)/$(IMAGE)
	docker rmi $(QUAY_REPO)/$(IMAGE)
	docker logout

push-to-gcr: configure-gcloud-cli
	docker tag $(IMAGE) $(GCR_REPO)/$(IMAGE)
	gcloud docker -- push $(GCR_REPO)/$(IMAGE)
	docker rmi $(GCR_REPO)/$(IMAGE)

configure-gcloud-cli-private:
	echo '$(GCLOUD_SERVICE_KEY_PRIVATE)' | base64 --decode > /tmp/gcloud-service-key-private.json
	gcloud auth activate-service-account $(GCLOUD_SERVICE_EMAIL_PRIVATE) --key-file=/tmp/gcloud-service-key-private.json
	gcloud --quiet config set project $(GOOGLE_PROJECT_ID_PRIVATE)
	gcloud --quiet config set compute/zone $(GOOGLE_COMPUTE_ZONE)

configure-gcloud-cli:
	echo '$(GCLOUD_SERVICE_KEY)' | base64 --decode > /tmp/gcloud-service-key.json
	gcloud auth activate-service-account $(GCLOUD_SERVICE_EMAIL) --key-file=/tmp/gcloud-service-key.json
	gcloud --quiet config set project $(GOOGLE_PROJECT_ID)
	gcloud --quiet config set compute/zone $(GOOGLE_COMPUTE_ZONE)
