#!/bin/bash

cd ./lambda
go mod tidy
GOOS=linux GOARCH=amd64 go build -o main main.go
chmod +x main
zip main.zip *
