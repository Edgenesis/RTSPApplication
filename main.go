package main

import (
	"github.com/Edgenesis/RTSPApplication/pkg/rtspRecord"
	"github.com/edgenesis/shifu/pkg/logger"
	"net/http"
	"os"
)

var serverListenPort = os.Getenv("SERVER_LISTEN_PORT")

const (
	storePersistFilePath  = "/data/mapStore"
	videoPersistDirectory = "/data/video"
)

func main() {
	rtspRecord.InitPersistMap(storePersistFilePath)
	err := os.MkdirAll(videoPersistDirectory, os.ModePerm)
	if err != nil {
		logger.Error(err)
		return
	}
	rtspRecord.VideoSavePath = videoPersistDirectory
	mux := http.NewServeMux()
	mux.HandleFunc("/register", rtspRecord.Register)
	mux.HandleFunc("/unregister", rtspRecord.Unregister)
	mux.HandleFunc("/update", rtspRecord.Update)
	logger.Infof("Listening at %#v", serverListenPort)
	err = http.ListenAndServe(serverListenPort, mux)
	if err != nil {
		logger.Error(err)
		return
	}
}
