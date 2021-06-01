FROM golang:1.15-alpine AS builder

ENV GOFLAGS="-mod=readonly"
ENV CGO_ENABLED=0

RUN apk add --update --no-cache ca-certificates git

RUN mkdir -p /workspace
WORKDIR /workspace

COPY go.* /workspace/
RUN go mod download

COPY . /workspace
RUN go build -o tcheck .


FROM alpine:3.12

RUN apk add --update --no-cache ca-certificates tzdata bash curl

SHELL ["/bin/bash", "-c"]

# set up nsswitch.conf for Go's "netgo" implementation
# https://github.com/gliderlabs/docker-alpine/issues/367#issuecomment-424546457
RUN test ! -e /etc/nsswitch.conf && echo 'hosts: files dns' > /etc/nsswitch.conf

COPY --from=builder /workspace/tcheck /usr/local/bin/tcheck
