FROM golang:latest
MAINTAINER Tommy Huang

#Set destination for copy
WORKDIR /app

#Download GO modules
COPY go.mod go.sum .
RUN go mod download

COPY src/*.go ./

#Build
RUN GOOS=linux go build src/main.go -o ./go-gin-microservice
EXPOSE 8080


CMD ["/go-gin-microservice"]
