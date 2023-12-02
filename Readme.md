# 简单的镜像构建以及 K8S 部署


## 目的：讲一个 HTTP 服务部署在 K8S，对公网暴露


## 流程
- 1 编写 Dockerfile
- 2 构建镜像
- 3 推送镜像仓
- 4 创建 K8S 集群
- 5 部署服务
- 7 访问服务

## 步骤

### 1. 编写 Dockerfile

```dockerfile
FROM golang:1.17-alpine

WORKDIR /app

# 复制 go.mod 和 go.sum 文件以下载依赖
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制整个项目到镜像中
COPY . .

# 构建可执行文件
RUN go build -o main .

# 暴露端口
EXPOSE 9999

CMD ["./main"]

```
### 2. 构建镜像

> 注意：如果你构建镜像的机器和 K8S 的机器的 CPU 架构不一样，则需要指定镜像架构 <br>
> 比如我构建镜像的机器是 arm64,K8S 机器是 amd64,则需要指定 `--platform=linux/amd64`


```bash
docker buildx build -t my-http-amd64:1.0 --platform linux/amd64 .
```

### 3. 推送镜像仓
> 镜像仓必须是你的 K8S 机器可以拉取到到镜像仓。可以是 Docker Hub,阿里云镜像仓库,私有镜像仓库等


```bash
docker login -u username -p password myregistry.example.com
docker tag my-http-amd64:1.0 myregistry.example.com/my-http-amd64:v1.0
docker push myregistry.example.com/my-http-amd64:v1.0
```

### 4. 创建 K8S 集群
使用 K3S 或者 K8S 都可以

```bash
# 1. 创建命名空间
kubectl create namespace my-namespace
```


### 5. 部署服务

deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jerry-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jerry-app
  template:
    metadata:
      labels:
        app: jerry-app
    spec:
      containers:
        - name: jerry-app
          image: registry.cn-hangzhou.aliyuncs.com/kipchoge-test/kipchoge-test-repo:1.0
          ports:
            - containerPort: 9999


```
service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: jerry-app
spec:
  selector:
    app: jerry-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9999
      nodePort: 30000
  type: NodePort
```

```bash
kubectl -n my-namespace apply -f deployment.yaml
kubectl -n my-namespace apply -f service.yaml
```

### 7. 访问服务

#### 集群内访问服务
- 使用 Service 的 ClusterIP+ServicePort 访问
```bash
[root@jerry-master ~]# kubectl -n my-namespace get svc
NAME        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
jerry-app   NodePort   10.43.15.184   <none>        80:30000/TCP   34m
[root@jerry-master ~]# curl 10.43.15.184:80/hello
{"message":"Hello, World!"}
```
- 使用 POD IP+容器端口 访问
```bash
[root@jerry-master ~]# kubectl -n my-namespace get po jerry-app-fb9975b54-zrb47 -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
jerry-app-fb9975b54-zrb47   1/1     Running   0          50m   10.42.0.98   jerry-master   <none>           <none>
[root@jerry-master ~]# curl 10.42.0.98:9999/hello
{"message":"Hello, World!"}
```
- 使用节点公网IP+NodePort 访问 。记得安全组开端口
```bash
lihonglei@bogon ~ % curl 139.9.69.244:30000/hello
{"message":"Hello, World!"}%
```




