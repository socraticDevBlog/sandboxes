# Kubernetes Init Container Project (no Istio)

This project contains a simple deployment configuration for an Nginx web
server, which includes an init container for proof of concept purposes.

__tl;dr__
Init containers configured in a Deployment will run everytime a new pod replicas get created

## Project Structure

- **deployment.yaml**: This file contains the deployment
  configuration for the Nginx application. It defines a main container running
  Nginx and an init container that runs before the Nginx container. The init
  container is confiured to output a string of text and a timestamp to a
  centralized file (witness_file.txt)

- **volume.yaml**: defines a PersistentVolume (PV) and a PersistentVolumeClaim (PVC), allowing pods to share a centralized storage location (/mnt/shared-data) with ReadWriteMany access mode for persistent data across pod restarts or multiple replicas.

## Deployment Instructions

1. Ensure you have a Kubernetes cluster running.
2. Apply the volume configurations
   ```
   kubectl apply -f volume.yaml
   ```

## Goal

Hands-on lab to understand init containers behavior on applicative pods
starting, scaling up, and re-starting

every time the Init-container runs, it will print a line in a centralized file
(PersistentVolume) independent of the deployment's lifecycle

Let's call it the `witness file`


### starting

create a new deployment
```
kubectl apply -f deployment.yaml
```

check your pod got created
```
kubectl get pods
```

use this pod to read the content of the `witnessfile`

```
kubectl exec -it <pod's name> -- cat /usr/share/nginx/html/witness_file.txt
```

### scaling up to 3 pods

```
kubectl scale deployment nginx-deployment --replicas=3
```

perform the previous `kubectl exec ...` operation to read the `witness file`.
Expect to find 2 new lines: init container has ran one time for each new pod

QED: Init containers configured in a Deployment will run everytime a new pod replicas get created

