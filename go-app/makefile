# https://go-app.dev/start
build:
	GOARCH=wasm GOOS=js go build -o web/app.wasm
	go build

run: build
	./go-app