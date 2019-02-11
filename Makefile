project=tekwrks
name=website
version=1.0.0

all: Makefile .image-timestamp
	@touch .image-timestamp

build: src/ node_modules/ sw-precache-config.js package.json yarn.lock
	yarn build

.image-timestamp: build Dockerfile public/
	docker image build \
		-t ${project}/${name}:${version} .

.PHONY:run
run:
	docker container run \
		--rm \
		--name ${project}-${name}-dev \
		--env-file .env \
		-p 7001:7001 \
		-t ${project}/${name}:${version}

.PHONY:kill
kill:
	docker rm $$( \
	docker kill $$( \
	docker ps -aq \
	--filter="name=${project}-${name}-dev" ))

.PHONY: push
push:
	set -ex;
	docker tag \
		${project}/website:${version} \
		gcr.io/${project}/website:${version}
	docker push \
		gcr.io/${project}/website:${version}

