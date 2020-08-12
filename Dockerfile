FROM golang:1.14.2 as builder
WORKDIR /go/src/github.com/eeveebank/exporter-merger
COPY . .
RUN CGO_ENABLED=0 go build -o exporter-merger 

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
COPY --from=builder /go/src/github.com/eeveebank/exporter-merger/merger.yaml /
COPY --from=builder /go/src/github.com/eeveebank/exporter-merger/exporter-merger /
ENTRYPOINT ./exporter-merger
