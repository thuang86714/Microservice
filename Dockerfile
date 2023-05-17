FROM golang:latest
RUN mkdir /app
ADD ./pkg /app/
WORKDIR /app
RUN go get "github.com/gorilla/mux"
RUN go get "github.com/gin-gonic/gin"
RUN go build -o main .
CMD ["/app/main"]