package main

import (
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("GATEWAY_API_PORT")
	mux := http.NewServeMux()

	http.ListenAndServe(port, mux)
}
