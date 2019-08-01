# Spark Standalone on Kubernetes

## Install

1. Download Spark and unpack
2. cd spark-2.4.3-bin-hadoop2.7
3. Download lapack 3.0.8 //Replace with step in Dockerfile 
4. git clone vrann/spark-k8s-template
5. Build and copy application
6. Build image, run `docker build -t spark-hadoop:1.0.35 -f spark-k8s-template/Dockerfile .`
7. Start master, run `kubectl apply -f spark-k8s-template/spark-master-deployment.yaml`
8. Start master service, run `kubectl apply -f spark-k8s-template/spark-worker-service.yaml`
9. verify that master UI is working, go to http://localhost:8083
10. Start workers, run `kubectl apply -f spark-k8s-template/spark-worker-deployment.yaml`
11. Verify 6 containers are running, one for master and five for workers, run `kubectl get pods`

## Run Application

1. log into worker container, run `kubectl exec -it spark-worker-76574dc79-kpt5b /bin/bash`
2. `./bin/spark-submit --class "SparkALS" --master spark://spark-master.default.svc.cluster.local:7077 --conf spark.driver.bindAddress=$MY_POD_IP --conf spark.local.ip=$MY_POD_IP --conf spark.driver.host=$MY_POD_IP --deploy-mode client  /opt/spark/data/spark-counter_2.11-0.4.jar`

## Description

