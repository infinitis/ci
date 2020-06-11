IMAGE_NAME=ci
CONTAINER_NAME=ci-test

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d -p "8080:80" --name $(CONTAINER_NAME) $(IMAGE_NAME)

start: build
	-docker run -it --rm -p "8080:80" $(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

push: build
ifndef REGISTRY
	$(error REGISTRY must be defined)
endif
ifndef VERSION
	$(MAKE) push VERSION=`git describe 2>/dev/null || cat tag`
else
	docker tag $(IMAGE_NAME) $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
endif