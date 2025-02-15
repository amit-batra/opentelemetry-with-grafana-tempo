# Define the Docker image and Kubernetes namespace
IMAGE_NAME = abatra/hello-world-with-telemetry-app
KUBECTL_NAMESPACE = hello-world-ns

# Target to build the Docker image
build:
	docker buildx build -t $(IMAGE_NAME) .

# Target to push the Docker image to the Docker Hub
push: docker-login
	docker push $(IMAGE_NAME)

# Target to create the Kubernetes namespace
create-namespace:
	kubectl create namespace $(KUBECTL_NAMESPACE)

# Target to delete the Kubernetes namespace
delete-namespace:
	kubectl delete namespace $(KUBECTL_NAMESPACE)

# Target to deploy the Docker image to the Kubernetes cluster
deploy-app:
	kubectl --namespace=$(KUBECTL_NAMESPACE) apply -f hello-world-deployment.yaml

# Target to delete the Docker image from the Kubernetes cluster
delete-app:
	kubectl --namespace=$(KUBECTL_NAMESPACE) delete -f hello-world-deployment.yaml

# Target to clean up the Docker image
clean-app:
	docker image rm $(IMAGE_NAME)

# Target to view the logs of the Docker container
logs:
	kubectl --namespace=$(KUBECTL_NAMESPACE) logs --follow --selector app=hello-world

# Target to forward the port of the Docker container
port-forward:
	kubectl --namespace=$(KUBECTL_NAMESPACE) port-forward svc/hello-world-service 8080:8080 &
	kubectl --namespace=$(KUBECTL_NAMESPACE) port-forward svc/grafana 3000:80 &

# Target to login to Docker Hub
docker-login:
	@./docker-login.sh