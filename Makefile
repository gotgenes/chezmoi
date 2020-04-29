GOLANGCI_LINT_VERSION=1.25.0

.PHONY: default
default: generate run test lint format

.PHONT: generate
generate:
	go generate

.PHONY: run
run:
	go run . --version

.PHONY: test
test:
	go test -race ./...

.PHONY: lint
lint: ensure-golangci-lint
	./bin/golangci-lint run

.PHONY: format
format: ensure-gofumports
	find . -name \*.go | xargs ./bin/gofumports -local github.com/twpayne/chezmoi -w

.PHONY: ensure-tools
ensure-tools: ensure-gofumports ensure-golangci-lint

.PHONY: ensure-gofumports
ensure-gofumports:
	if [[ ! -x bin/gofumports ]] ; then \
		mkdir -p bin ; \
		( cd $$(mktemp -d) && go mod init tmp && GOBIN=${PWD}/bin go get mvdan.cc/gofumpt/gofumports ) ; \
	fi

.PHONY: ensure-golangci-lint
ensure-golangci-lint:
	if [[ ! -x bin/golangci-lint ]] || ( ./bin/golangci-lint --version | grep -Fqv "version ${GOLANGCI_LINT_VERSION}" ) ; then \
		curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- v${GOLANGCI_LINT_VERSION} ; \
	fi

.PHONY: release
release:
	goreleaser release \
		--rm-dist \
		${GORELEASER_FLAGS}

.PHONY: test-release
test-release:
	goreleaser release \
		--rm-dist \
		--skip-publish \
		--snapshot \
		${GORELEASER_FLAGS}

.PHONY: update-install.sh
update-install.sh:
	# FIXME install.sh is generated by godownloader, but godownloader is
	# currently unmaintained and needs to be run manually:
	# godownloader --repo=twpayne/chezmoi .goreleaser.yaml > assets/scripts/install.sh
	# cp assets/scripts/install.sh scripts/