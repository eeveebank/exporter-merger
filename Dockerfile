FROM golang:1.9-alpine AS build-env

RUN apk add --no-cache git make

# Configure Go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# Install Go Tools
RUN go get -u golang.org/x/lint/golint
RUN go get -u github.com/golang/dep/cmd/dep

ADD . /go/src/github.com/rebuy-de/exporter-merger/
RUN cd /go/src/github.com/rebuy-de/exporter-merger/ && CGO_ENABLED=0 make install

# final stage
FROM alpine
MAINTAINER Platform Engineering <platform@mettle.co.uk>

ARG git_repository="Unknown"
ARG git_commit="Unknown"
ARG git_branch="Unknown"
ARG built_on="Unknown"

LABEL git.repository=$git_repository
LABEL git.commit=$git_commit
LABEL git.branch=$git_branch
LABEL build.on=$built_on
WORKDIR /app
COPY --from=build-env /go/src/github.com/rebuy-de/exporter-merger/merger.yaml /app/
COPY --from=build-env /go/bin/exporter-merger /app/
ENTRYPOINT ./exporter-merger
