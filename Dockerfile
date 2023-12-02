# 使用 golang 作为基础镜像
FROM golang:1.17-alpine

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件以下载依赖
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制整个项目到镜像中
COPY . .

RUN go env

# 构建可执行文件
RUN go build -o main .

# 暴露端口
EXPOSE 9999

CMD ["./main"]