.PHONY: help build run dev stop clean logs deps status test-register test-login test-me test-refresh test-logout test-all

APP_NAME = auth-service
LOG_FILE = app.log

## help: Show this help message
help:
	@echo ""
	@echo "  Umix Auth Service"
	@echo "  ─────────────────────────────────────────────"
	@echo ""
	@echo "  Server:"
	@echo "    make build          Build the binary"
	@echo "    make run            Build and run (foreground)"
	@echo "    make dev            Build and run (background + logging)"
	@echo "    make stop           Stop the background server"
	@echo "    make logs           Show live server logs (Ctrl+C to exit)"
	@echo "    make clean          Remove binary, logs, and database"
	@echo "    make deps           Download Go dependencies"
	@echo "    make status         Show server and database status"
	@echo ""
	@echo "  API Tests:"
	@echo "    make test-all       Run all API tests"
	@echo "    make test-register  Test user registration"
	@echo "    make test-login     Test user login"
	@echo "    make test-me        Test get profile (with token)"
	@echo "    make test-refresh   Test token refresh"
	@echo "    make test-logout    Test user logout"
	@echo ""
	@echo "  Quick Start:"
	@echo "    make deps           # first time only"
	@echo "    make dev            # start server"
	@echo "    make test-all       # test endpoints"
	@echo "    make logs           # watch logs"
	@echo "    make stop           # stop server"
	@echo ""

## build: Build the binary
build:
	CGO_ENABLED=1 go build -o $(APP_NAME) .

## run: Build and run in foreground
run: build
	./$(APP_NAME)

## dev: Build and run in background with logging
dev: build
	@echo "Starting $(APP_NAME) in background..."
	./$(APP_NAME) >> $(LOG_FILE) 2>&1 & echo $$! > .pid
	@sleep 2
	@if kill -0 $$(cat .pid) 2>/dev/null; then \
		echo "Running (PID: $$(cat .pid)) | Logs: $(LOG_FILE)"; \
	else \
		echo "Failed to start! Check $(LOG_FILE)"; \
	fi

## stop: Stop the background server
stop:
	@if [ -f .pid ]; then \
		kill $$(cat .pid) 2>/dev/null && echo "Stopped (PID: $$(cat .pid))" || echo "Not running"; \
		rm -f .pid; \
	else \
		echo "No .pid file found"; \
	fi

## logs: Show live server logs
logs:
	tail -f $(LOG_FILE)

## clean: Remove build artifacts and database
clean: stop
	rm -f $(APP_NAME) $(LOG_FILE) .pid database/auth.db

## deps: Download Go dependencies
deps:
	GOPROXY=https://goproxy.io,direct go mod tidy

## status: Show server and database status
status:
	@echo ""
	@echo "  Status"
	@echo "  ─────────────────────────────────────────────"
	@echo ""
	@printf "  Server:    "
	@if [ -f .pid ] && kill -0 $$(cat .pid) 2>/dev/null; then \
		echo "Running (PID: $$(cat .pid))"; \
	else \
		echo "Stopped"; \
	fi
	@printf "  Health:    "
	@curl -s --max-time 2 http://localhost:8080/health > /dev/null 2>&1 && echo "OK (http://localhost:8080)" || echo "Unreachable"
	@printf "  Database:  "
	@if [ -f database/auth.db ]; then \
		echo "Exists ($$(du -h database/auth.db | cut -f1 | xargs))"; \
	else \
		echo "Not created yet"; \
	fi
	@printf "  Log file:  "
	@if [ -f $(LOG_FILE) ]; then \
		echo "$(LOG_FILE) ($$(wc -l < $(LOG_FILE) | xargs) lines)"; \
	else \
		echo "No logs yet"; \
	fi
	@printf "  Binary:    "
	@if [ -f $(APP_NAME) ]; then \
		echo "Built ($$(du -h $(APP_NAME) | cut -f1 | xargs))"; \
	else \
		echo "Not built"; \
	fi
	@echo ""

# ── API Tests ──────────────────────────────────────────

test-register:
	@curl -s -X POST http://localhost:8080/auth/register \
		-H "Content-Type: application/json" \
		-d '{"name":"Ali","email":"ali@test.com","password":"123456"}' | python3 -m json.tool

test-login:
	@curl -s -X POST http://localhost:8080/auth/login \
		-H "Content-Type: application/json" \
		-d '{"email":"ali@test.com","password":"123456"}' | python3 -m json.tool

test-me:
	@TOKEN=$$(curl -s -X POST http://localhost:8080/auth/login \
		-H "Content-Type: application/json" \
		-d '{"email":"ali@test.com","password":"123456"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])"); \
	curl -s http://localhost:8080/auth/me \
		-H "Authorization: Bearer $$TOKEN" | python3 -m json.tool

test-refresh:
	@REFRESH=$$(curl -s -X POST http://localhost:8080/auth/login \
		-H "Content-Type: application/json" \
		-d '{"email":"ali@test.com","password":"123456"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['refresh_token'])"); \
	curl -s -X POST http://localhost:8080/auth/refresh \
		-H "Content-Type: application/json" \
		-d "{\"refresh_token\":\"$$REFRESH\"}" | python3 -m json.tool

test-logout:
	@TOKEN=$$(curl -s -X POST http://localhost:8080/auth/login \
		-H "Content-Type: application/json" \
		-d '{"email":"ali@test.com","password":"123456"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])"); \
	curl -s -X POST http://localhost:8080/auth/logout \
		-H "Authorization: Bearer $$TOKEN" | python3 -m json.tool

test-all: test-register test-login test-me test-refresh test-logout
