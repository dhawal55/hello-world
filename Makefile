build := build
image_tag := 1.0

app_name := hello-world
namespace := default
image := gitlab-registry.nordstrom.com/k8s/platform-bootstrap/hello-world:$(image_tag)

.PHONY: build/app test_app
.PHONY: build/image push/image deploy teardown clean

$(build):
	mkdir -p "$@"

$(app_name): *.go | $(build)
	# Build golang app for local OS
	go build -o $(app_name) -ldflags "-X main.Version=$(image_tag)"

test_app:
	go test

build/image: Dockerfile
	docker build -t $(image) .

push/image: build/image
	docker push $(image)

$(build)/%.yaml: templates/%.yaml | $(build)
	@echo "Templating $(@F)"
	sed  -e 's|$$app_name|${app_name}|g' -e 's|$$namespace|${namespace}|g' -e 's|$$image|${image}|g' "$<" > "$@"
	# sed -e 's/\$namespace/${namespace}' "$<" > "$@"

TEMPLATES := $(shell find ./templates -name '*.yaml' -exec /usr/bin/basename {} \;)
OBJECTS := $(addprefix $(build)/,$(TEMPLATES))

deploy: $(OBJECTS)
	kubectl apply --record -f $(build)

teardown: $(OBJECTS)
	kubectl delete -f $(build)

clean:
	rm -rf $(build)
