#!/bin/sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install grafana grafana/grafana --namespace hello-world-ns --create-namespace
helm upgrade --install tempo grafana/tempo --namespace hello-world-ns --create-namespace
