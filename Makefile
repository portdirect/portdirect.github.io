# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash


build:
	@echo "Building site"
	cd ./source; hugo --destination ../


devel:
	@echo "Running local development server"
	cd ./source; hugo server --disableFastRender -D
