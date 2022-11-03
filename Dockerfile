#
# Stage 1
#
FROM library/golang:1.19 as builder

ENV APP_DIR $GOPATH/src/github.com/chartmuseum/ui
RUN mkdir -p $APP_DIR
ADD . $APP_DIR

# Compile the binary and statically link
RUN cd $APP_DIR && \
    go build -ldflags '-w -s' -o /chartmuseum-ui && \
    cp -r views/ /views && \
    cp -r static/ /static

#
# Stage 2
#
FROM alpine:3.8
RUN apk add --no-cache curl cifs-utils ca-certificates \
    && adduser -D -u 1000 chartmuseum
COPY --from=builder /chartmuseum-ui /chartmuseum-ui
COPY --from=builder /views /views
COPY --from=builder /static /static
USER 1000
ENTRYPOINT ["/chartmuseum-ui"]
