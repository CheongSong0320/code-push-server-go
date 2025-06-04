FROM golang:1.21 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o code-push-server-go main.go

FROM alpine:3.19

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /app/code-push-server-go .
COPY --from=builder /app/config ./config

ENV PORT=8080
EXPOSE 8080

CMD ["./code-push-server-go"]
