# Kubernetes test with Angular Sample

kubectl apply -f angular-deploy.yaml

kubectl get pods,svc

NAME                                READY   STATUS    RESTARTS   AGE
pod/angular-sample-f448f566-5wtpt   1/1     Running   0          117s

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/angular-sample   NodePort    10.106.110.41   <none>        8080:30001/TCP   118s
service/kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP          4h54m

## To install the Kubernetes Dashboard

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard