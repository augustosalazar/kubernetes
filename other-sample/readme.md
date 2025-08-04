
# start the docker containers
docker-compose up -d

# test the web service
curl -s http://localhost:8080/clientes
curl -s -X POST http://localhost:8080/clientes -H "Content-Type: application/json" -d '{"nombre":"Ana Pérez","email":"ana.perez@example.com"}'
curl -s http://localhost:8080/clientes/1
curl -s -X PUT http://localhost:8080/clientes/1 -H "Content-Type: application/json" -d '{"nombre":"Ana María Pérez","email":"ana.m.perez@example.com"}'
curl -s -X DELETE http://localhost:8080/clientes/1 -w "\nHTTP Status: %{http_code}\n"
curl -s http://localhost:8080/clientes/1 -w "\nHTTP Status: %{http_code}\n"


REM 1. Arrancar Minikube
minikube start
REM → Verifica el estado
minikube status

REM 2. Configurar CMD para usar el Docker daemon de Minikube
FOR /f "tokens=*" %i IN ('minikube docker-env --shell cmd') DO @%i
REM → Comprueba que Docker apunta a Minikube
docker info | findstr "Name:"

REM 3. Construir las imágenes dentro de Minikube
docker build -t clientes-db:latest .\db
docker build -t clientes-web:latest .\web
REM → Lista imágenes para confirmar
docker images | findstr "clientes-"

REM 4. Crear el namespace
kubectl create namespace clientes-app
REM → Asegúrate de que exista
kubectl get namespace clientes-app

REM 5. Crear el Secret con la contraseña de MySQL
kubectl apply -n clientes-app -f mysql-secret.yaml
REM → Comprueba que esté ahí
kubectl get secret mysql-secret -n clientes-app

REM 6. Crear el PVC para la base de datos
kubectl apply -n clientes-app -f mysql-pvc.yaml
REM → Verifica el estado del PVC
kubectl get pvc -n clientes-app

REM 7. Desplegar MySQL
kubectl apply -n clientes-app -f mysql-deploy.yaml
REM → Comprueba que el Deployment exista
kubectl get deployment mysql -n clientes-app

REM 8. Exponer MySQL como ClusterIP
kubectl apply -n clientes-app -f mysql-svc.yaml
REM → Verifica el Service
kubectl get svc mysql -n clientes-app

REM 9. Desplegar el servicio web
kubectl apply -n clientes-app -f web-deploy.yaml
REM → Comprueba el Deployment
kubectl get deployment web -n clientes-app

REM 10. Exponer el servicio web con NodePort
kubectl apply -n clientes-app -f web-svc.yaml
REM → Verifica el Service y su puerto
kubectl get svc web -n clientes-app

REM 11. Esperar a que todos los pods estén listos
kubectl rollout status deployment/mysql -n clientes-app
kubectl rollout status deployment/web -n clientes-app
REM → Lista los pods y comprueba su estado
kubectl get pods -n clientes-app -o wide

REM 12. Obtener la URL de acceso al servicio web
minikube service web -n clientes-app --url



kubectl port-forward svc/web 8080:80 -n clientes-app

curl -s http://localhost:8080/clientes
curl -s -X POST http://localhost:8080/clientes -H "Content-Type: application/json" -d "{\"nombre\":\"María Ruiz\",\"email\":\"maria.ruiz@example.com\"}"