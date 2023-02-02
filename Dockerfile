# Build the manager binary
FROM --platform=$BUILDPLATFORM golang:1.19.2 as builder

WORKDIR /rtsp

ENV GO111MODULE=on

COPY go.mod go.mod
COPY go.sum go.sum
COPY pkg pkg
COPY main.go main.go

RUN go mod download -x

# Build the Go app
ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -o /output/rtspRecord main.go

FROM jrottenberg/ffmpeg:5.1.2-alpine313
WORKDIR /
COPY --from=builder /output/rtspRecord rtspRecord

# Command to run the executable
USER 65532:65532
ENTRYPOINT ["/rtspRecord"]
