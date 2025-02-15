# Hello World with Telemetry App

A Spring Boot application demonstrating distributed tracing using OpenTelemetry, designed to run in Kubernetes.

## Features

- Spring Boot REST API with a simple hello world endpoint
- OpenTelemetry integration for distributed tracing
- Docker containerization
- Kubernetes deployment configuration
- Makefile for easy operations

## Prerequisites

- Java 11 or higher
- Maven 3.8+
- Docker
- Kubernetes cluster
- Make

## Project Structure

```
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/demo/
│       │       └── DemoApplication.java
│       └── resources/
│           └── application.properties
├── Dockerfile
├── install-grafana-tempo.sh
├── Makefile
├── hello-world-deployment.yaml
├── pom.xml
└── docker-login.sh
```

## Getting Started

### Setting up Prerequisites

1. Ensure that Docker is installed and running.

2. Initialize the Kubernetes Cluster.
```bash
minikube config set driver docker
minikube start
```

3. Create a new namespace for the application, and switch to it.
```bash
kubectl create namespace hello-world-ns
kubectl config set-context --current --namespace=hello-world-ns
```
Verify that the namespace was created and is the current namespace.
```bash
kubectl config get-contexts
```
You should see the following output:
```
CURRENT   NAME        CLUSTER       AUTHINFO     NAMESPACE
*         minikube    minikube      minikube     hello-world-ns
```

4. Install Grafana & Tempo in the namespace.
```bash
./install-grafana-and-tempo.sh
```

5. Confirm that the Grafana and Tempo services are running.
```bash
kubectl get svc
```
You should see the following services listed:
```
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
grafana      ClusterIP   10.96.100.100   <none>        80/TCP    10s
tempo        ClusterIP   10.96.100.101   <none>        9000/TCP  10s
```

6. Add Tempo connection to Grafana.
   1. Forward Grafana service to LocalHost:3000
   ```bash
   kubectl --namespace=hello-world-ns port-forward svc/grafana 3000:80 &
   ```
   2. Extract the Grafana admin password.
   ```bash
   GRAFANA_PASSWORD=$(kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
   echo "GRAFANA_PASSWORD: $GRAFANA_PASSWORD"
   ```
   3. Open your browser and navigate to http://localhost:3000
   4. Login with the `admin` user and the password extracted in the previous step.
   5. Navigate to `Home` -> `Connections` -> `Data Sources` -> `Add data source` -> `Tempo`
   6. Enter the following details:
      - `Name`: `Tempo`
      - `URL`: `http://tempo:3100`
   7. Click on `Save & Test`
   8. You should see a message indicating that the data source is working.

### Building the Application

1. Build the Docker image:
```bash
make build
```

1. Push the image to Docker Hub:
```bash
make push
```
You may be prompted to enter your Docker Hub credentials.

### Deploying to Kubernetes

1. Deploy the application:
```bash
make deploy-app
```

2. View the newly created deployment:
```bash
kubectl get all | grep hello-world
```
You should see the following output:
```
pod/hello-world-997b66c9d-m8jpw               1/1          Running          0    69s
service/hello-world-service             ClusterIP    10.105.12.207   8080/TCP    69s
deployment.apps/hello-world                   1/1                1        1      69s
replicaset.apps/hello-world-997b66c9d           1                1        1      69s
```

3. View the application logs:
```bash
make logs
```
Press `Ctrl+C` to stop the logs.

### Accessing the application endpoint through your browser

1. Ensure that the application is running.
```bash
make logs
```
2. Forward Hello World app to LocalHost:8080.
```bash
kubectl --namespace=hello-world-ns port-forward svc/hello-world-service 8080:8080 &
```
3. Open your browser and navigate to http://localhost:8080/hello
4. You should see a message indicating that the application is working.
5. Refresh the web page a few times to ensure that multiple traces are created.

### Viewing traces in Grafana
1. Navigate to Grafana at http://localhost:3000.
2. Navigate to `Home` -> `Explore` -> `Tempo`
3. Select the query type as `TraceQL`.
4. Enter the following query: `{trace:rootService="hello-world-service"}`
5. Click on `Run Query`
6. You should see the traces that were created by the application.

### Cleanup

1. Delete the hello-world app deployment:
```bash
make delete-app
```

2. Delete the hello-world-ns Kubernetes namespace:
```bash
make delete-namespace
```

3. Remove the Docker image:
```bash
make clean-app
```

4. (Optional) Delete the Kubernetes cluster:
```bash
minikube delete
```

## Built With

- Spring Boot 3.4.2
- OpenTelemetry Java SDK 1.47.0
- OpenTelemetry Spring Boot Starter 2.12.0
- Maven
- Docker
- Kubernetes

## License

This project is open-sourced under the MIT License.