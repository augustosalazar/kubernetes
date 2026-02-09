

# Example of emptyVolume usage
   
What it demonstrates

- Volume lives as long as the Pod

- Each replica gets its own storage

- Containers in the same Pod can share it


```bash
kubectl apply -f emptydir-deployment.yaml
```

Test it:


```bash
kubectl get pods
```
Now we go inside the pod (this command says Pick one Pod created by the Deployment named emptydir-demo. Then execute the command sh to get a shell inside the container):

```bash
kubectl exec -it deploy/emptydir-demo -- sh
```

```bash
cat /data/file.txt
```

Now we write something to the file:

```bash
echo "Hello, World!" > /data/file.txt
```

Exit the container

```bash
exit
```


Delete the pod and check the content of the file again (this command may take a while to execute because it needs to create a new Pod):

```bash
kubectl delete pod -l app=emptydir-demo
```

```bash
kubectl exec -it deploy/emptydir-demo -- sh
```

```bash
cat /data/file.txt
```