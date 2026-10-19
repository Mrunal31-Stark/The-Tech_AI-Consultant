.PHONY: up down logs build test test-task1 test-task2 test-task3

# Tests run inside the service images, so CI and local runs use the same toolchain.
RUN = docker compose run --rm --no-deps

up:
	docker compose up --build

down:
	docker compose down

logs:
	docker compose logs -f

build:
	docker compose build

test: build test-task1 test-task2 test-task3

test-task1:
	$(RUN) task1 sh -c "ruff check . && ruff format --check . && mypy app tests && pytest -q"

test-task2:
	$(RUN) task2 sh -c "npm run typecheck && npm test"

test-task3:
	$(RUN) task3 sh -c "ruff check . && ruff format --check . && mypy app tests && pytest -q"
