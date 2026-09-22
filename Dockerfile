FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.25.1-bookworm AS build

# TARGETARCH/TARGETOS must be top-level ARGs: inside a --platform=$BUILDPLATFORM
# stage, $TARGETPLATFORM equals the BUILD platform, which would compile an
# amd64 binary into the arm64 image (exec format error on the Pi).
ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

ENV CGO_ENABLED=0

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v -o /go/bin/unbound_exporter .

FROM gcr.io/distroless/static-debian12

COPY --from=build /go/bin/unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
