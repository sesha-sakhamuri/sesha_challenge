package test

import (
	"crypto/tls"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
)

func TestNginxServer(t *testing.T) {
	httpsUrl := "https://localhost"

	tlsConfig := &tls.Config{
		InsecureSkipVerify: true,
	}

	t.Log("Validate if HTTPS is serving the static website...")
	http_helper.HttpGetWithRetryWithCustomValidation(t, httpsUrl, tlsConfig, 10, 1*time.Second, func(statusCode int, body string) bool {
		return statusCode == 200
	})
}
