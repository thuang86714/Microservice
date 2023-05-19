FROM golang:latest
MAINTAINER Tommy Huang

#Set destination for copy
WORKDIR /app

#Download GO modules
COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

#Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-gin-microservice
EXPOSE 8080


CMD ["/go-gin-microservice"]
