# # single stage
# FROM golang
# WORKDIR /app
# ADD ./main.go /app/
# RUN cd /app && go build -o goapp
# ENTRYPOINT ./goapp

# build stage
FROM golang AS build-env
ADD ./main.go /src/
RUN cd /src && go build -o goapp

# final stage
FROM alpine
WORKDIR /app
COPY --from=build-env /src/goapp /app/
ENTRYPOINT ./goapp
