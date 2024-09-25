FROM --platform=$BUILDPLATFORM golang:bookworm AS build

RUN apt update
RUN apt install git build-essential libopus-dev autoconf libtool pkg-config -y

RUN git clone https://github.com/xiph/opus /opus
WORKDIR /opus

RUN git checkout v1.1.2
RUN ./autogen.sh
RUN ./configure

ENV PKG_CONFIG_PATH=":/opus"
RUN make


ENV CGO_CFLAGS_ALLOW="--libs: /opus/.libs/libopus.la"
RUN git clone https://github.com/imide/dca /dca
WORKDIR /dca/cmd/dca
RUN go mod download
RUN go build -trimpath -ldflags "-s -w" -o dca
RUN strip /dca/cmd/dca/dca

FROM alpine

RUN apk add --no-cache gcompat

COPY --from=build /dca/cmd/dca/dca /usr/bin/