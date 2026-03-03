#!/usr/bin/env bash

AZ_APP_SERVICE_NAME="20260302version-random-api-endpoint"
AZ_APP_SERVICE_PLAN_SKU="F1" # free tier
AZ_RESOURCE_GROUP_NAME="<my-resource-group>"
AZ_SUBSCRIPTION_ID="<my azure subscription id>"
RUNTIME="PYTHON:3.12"

az login

az account set --subscription "$AZ_SUBSCRIPTION_ID"

cd app || exit

az webapp up \
--name "$AZ_APP_SERVICE_NAME" \
--resource-group "$AZ_RESOURCE_GROUP_NAME" \
--runtime $RUNTIME \
--sku $AZ_APP_SERVICE_PLAN_SKU

az webapp config set \
--name "$AZ_APP_SERVICE_NAME" \
--resource-group "$AZ_RESOURCE_GROUP_NAME" \
--startup-file "uvicorn app:app --host 0.0.0.0 --port 8000"
