package rtspRecord

import (
	"encoding/json"
	"fmt"
	"github.com/edgenesis/shifu/pkg/logger"
	"github.com/edgenesis/shifu/pkg/telemetryservice/utils"
	"io"
	"net/http"
)

const (
	PasswordSecretField = "password"
	UsernameSecretField = "username"
)

// trans: transfer the raw http body to request structure
func trans[T Request](r *http.Request) (*T, error) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		return nil, err
	}
	request := new(T)
	err = json.Unmarshal(body, request)
	if err != nil {
		return nil, err
	}
	logger.Infof("request: %v", *request)
	return request, nil
}

// getCredential from k8s cluster
func getCredential(name string) (string, string, error) {
	secret, err := utils.GetSecret(name)
	if err != nil {
		return "", "", err
	}
	password, exist := secret[PasswordSecretField]
	if !exist {
		return "", "", fmt.Errorf("the %v field not found in telemetry secret", PasswordSecretField)
	}
	username, exist := secret[UsernameSecretField]
	if !exist {
		return "", "", fmt.Errorf("the %v field not found in telemetry secret", UsernameSecretField)
	}
	return username, password, nil
}
