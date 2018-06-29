package main

import (
	"os"
	"time"
)

func main() {
	filePath := os.Getenv("FILE_PATH")

	f, err := os.OpenFile(filePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	for {
		f.WriteString(time.Now().Format(time.RFC3339) + ": Hello World\n")
		f.Sync()
		time.Sleep(5 * time.Second)
	}
}
