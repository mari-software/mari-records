package main

import (
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("APP_MARI_PROFILE_PORT")
	mux := http.NewServeMux()

	http.ListenAndServe(port, mux)
}
