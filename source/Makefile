
image:
	@echo "Building and pushing image"
	podman build -t docker.io/port/hugo:latest .
	#podman login --authfile ~/.docker/auth.json docker.io
	podman push --authfile ~/.docker/auth.json docker.io/port/hugo:latest

build:
	@echo "Building site"
	# See: https://github.com/rhatdan/moby1/commit/e6473011583967df4aa5a62f173fb421cae2bb1e#diff-3447382c025de2b57389ba75d45fae85R362
	podman run --rm \
		--read-only \
		--net none \
		--volume ../:/src/site:Z,rw \
		--workdir /src/site/source \
		docker.io/port/hugo:latest \
			hugo --destination ../

terminal:
	@echo "Running interactive terminal"
	podman run --rm \
		-it \
		--read-only \
		--net host \
		--volume ../:/src/site:Z,rw \
		--workdir /src/site/source \
		docker.io/port/hugo:latest \
			bash

devel:
	@echo "Running local development server"
	podman run --rm \
		--read-only \
		--net host \
		--volume ../:/src/site:Z,rw \
		--workdir /src/site/source \
		docker.io/port/hugo:latest \
			hugo server --disableFastRender -D

push:
	@echo "pushing repo"
	git add ../
	git commit -s -m "$(shell date)"
	git push