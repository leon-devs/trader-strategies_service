# syntax=docker/dockerfile:1.7
FROM golang:1.25 AS builder

ARG TARGETOS
ARG TARGETARCH
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH

RUN echo "Building image for OS '$GOOS' and ARCH '$GOARCH'"

WORKDIR /src

COPY cmd ./cmd
COPY pkg ./pkg
COPY go.mod go.sum ./

RUN go mod download

RUN CGO_ENABLED=0 GO111MODULE=on go build -a -o application cmd/app/main.go

RUN rm -f "${HOME}/.netrc"

FROM alpine AS main

RUN apk update
RUN apk add --no-cache bash curl jq

WORKDIR /

COPY --from=builder /src/application .

ENTRYPOINT ["./application"]
