ENVTEST ?= $(LOCALBIN)/setup-envtest
PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
IMAGE_VERSION = nightly

fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: test
test: fmt envtest ## Run tests.
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) -p path)" go test -v -race -coverprofile=coverage.out -covermode=atomic $(shell go list ./... | grep -v -E '/cmd|/mockdevice')

.PHONY: envtest
envtest: $(ENVTEST) ## Download envtest-setup locally if necessary.
$(ENVTEST): $(LOCALBIN)
	test -s $(LOCALBIN)/setup-envtest || GOBIN=$(LOCALBIN) go install sigs.k8s.io/controller-runtime/tools/setup-envtest@latest

buildx-build-image-rtsp-record:
	docker buildx build --platform=linux/$(shell go env GOARCH) \
		--build-arg PROJECT_ROOT="${PROJECT_ROOT}" ${PROJECT_ROOT} \
		-t edgehub/rtsp-record:${IMAGE_VERSION} --load

buildx-build-image-ffmpeg:
	docker buildx build --platform=linux/$(shell go env GOARCH) \
		--build-arg PROJECT_ROOT="${PROJECT_ROOT}/videos" ${PROJECT_ROOT}/videos \
		-t edgehub/ffmpeg:${IMAGE_VERSION} --load

load: buildx-build-image-rtsp-record buildx-build-image-ffmpeg
	kind load docker-image edgehub/rtsp-record:${IMAGE_VERSION}
	kind load docker-image edgehub/ffmpeg:${IMAGE_VERSION}
