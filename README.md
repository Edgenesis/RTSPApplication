# RTSPApplication
the application to record the rtsp stream into file

## Setup the cluster

Install the [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), and create a cluster:

```bash
kind create cluster
```

Set up the rbac:

```bash
kubectl apply -f ./example/pre
```

## Build and load the image

```bash
make load
```

## Deploy the RTSPApplication

```bash
kubectl apply -f ./example/deploy
```

## Test it

### Simple Unit Test

```bash
make test
```

### e2e test

1. create a mock rtsp server, a ffmpeg service that sends the rtsp stream forever and a curl client

   ```bash
   kubectl apply -f ./example/mocktest/client.yaml
   kubectl apply -f ./example/mocktest/rtsp-server.yaml 
   kubectl apply -f ./example/mocktest/ffmpeg.yaml
   ```

2. create a secret store the username and password of the rtsp server

   ```bash
   kubectl create secret generic test-secret --from-literal=username=admin --from-literal=password=password -n shifu-app
   ```

3. send request inside the curl container

   ```bash
   kubectl exec curl -it -n shifu-app -- /bin/bash
   ```
   
   For exmaple:

   ```bash
   curl --header "Content-Type: application/json" \
   --request POST --data '{"deviceName":"xyz", "secretName": "test-secret", "serverAddress":"rtsp-server.shifu-app.svc.cluster.local:8554/mystream", "record":true}' \
   rtsp-record.shifu-app.svc.cluster.local/register
   sleep 5s
   curl --header "Content-Type: application/json" \
   --request POST --data '{"deviceName":"xyz", "record":false}' \
   rtsp-record.shifu-app.svc.cluster.local/update
   sleep 1s
   curl --header "Content-Type: application/json" \
   --request POST --data '{"deviceName":"xyz", "record":true}' \
   rtsp-record.shifu-app.svc.cluster.local/update
   sleep 5s
   curl --header "Content-Type: application/json" \
   --request POST --data '{"deviceName":"xyz"}' \
   rtsp-record.shifu-app.svc.cluster.local/unregister
   ```

## Export the videos

Video is named `{device_name}_{clip_number}_{YYYY-MM-DD_hh-mm-ss}.mp4`. Use `kubect cp` to export the video.

```bash
POD=$(kubectl get pod -l app=rtsp-record-deployment -n shifu-app -o jsonpath="{.items[0].metadata.name}")
# list all videos
kubectl exec ${POD} -n shifu-app -- ls /data/video -hl
# export the video you want
kubectl cp shifu-app/$POD:/data/video/xyz_0_2023-01-19_08-14-35.mp4 ./video_save_name.mp4
```

## Uninstall

```bah
kubectl delete -f ./example/pre
```
