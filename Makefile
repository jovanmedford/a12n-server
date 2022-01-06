SOURCE_FILES:=$(shell find src/ -type f -name '*.ts')
DOCKER_IMAGE_NAME:=a12n-server

.PHONY:start run build test lint fix lint-fix start-dev watch inspect deploy
start: build
	node dist/src/app.js

run: start

build: dist/build

docker-build: build
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-run:
	docker run -it --rm --name $(DOCKER_IMAGE_NAME)-01 $(DOCKER_IMAGE_NAME)

test:
	npx nyc mocha

lint:
	npx tsc --noemit
	npx eslint --quiet 'src/**/*.ts' 'test/**/*.ts' 'knexfile.ts'

fix:
	npx eslint --quiet 'src/**/*.ts' 'test/**/*.ts' 'knexfile.ts' --fix

lint-fix: fix

migrate:
	npx knex migrate:latest

migrate-rollback:
	npx knex migrate:rollback

migration:
	npx knex migrate:make $(name) -x ts

start-dev:
	npx tsc-watch --onSuccess 'node dist/src/app.js'

watch:
	./node_modules/.bin/tsc --watch

.PHONY:clean
clean:
	rm -r node_modules dist

dist/build: $(SOURCE_FILES)
	./node_modules/.bin/tsc
	@# Touching this file so Makefile knows when it was last built.
	touch dist/build

inspect: build
	node --inspect dist/src/app.js

inspect-brk: build
	node --inspect-brk dist/src/app.js