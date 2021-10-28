package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strings"
)

func BaseName(s string) string {
	n := strings.LastIndexByte(s, '.')
	if n == -1 {
		return s
	}
	return s[:n]
}

func main() {
	pathRef := flag.String("path", "", "tx path (.cdc)")

	flag.Parse()

	path := *pathRef

	if path == "" {
		log.Fatal("path is empty")
	}

	bytes, err := os.ReadFile(path)
	if err != nil {
		log.Fatal(err)
	}

	lines := strings.Split(string(bytes), "\n")
	for i, s := range lines {
		if strings.HasPrefix(s, "import ") {
			newLine := strings.Replace(s, "../", "", -1)
			newLine = strings.Replace(newLine, "\"", "./", 1)
			newLine = strings.Replace(newLine, "\"", "", -1)
			lines[i] = newLine
		}
	}

	content := strings.Join(lines, "\n")
	converted := fmt.Sprintf("export default `\\\n%s`", content)
	err = os.WriteFile(BaseName(path)+".tsx", []byte(converted), 0644)
	if err != nil {
		log.Fatal(err)
	}
}
