.PHONY: help build up down restart logs ps clean db-shell api-shell test

# Default target
help:
	@echo "텅장히어로 서버 Docker 명령어"
	@echo ""
	@echo "사용법: make [명령어]"
	@echo ""
	@echo "명령어:"
	@echo "  build       Docker 이미지 빌드"
	@echo "  up          서비스 시작 (백그라운드)"
	@echo "  up-logs     서비스 시작 (로그 출력)"
	@echo "  down        서비스 중지"
	@echo "  restart     서비스 재시작"
	@echo "  logs        로그 확인"
	@echo "  logs-api    API 로그만 확인"
	@echo "  logs-db     DB 로그만 확인"
	@echo "  ps          실행 중인 컨테이너 확인"
	@echo "  clean       볼륨 포함 모든 리소스 삭제"
	@echo "  db-shell    PostgreSQL 쉘 접속"
	@echo "  api-shell   API 컨테이너 쉘 접속"
	@echo "  health      헬스체크"

# Build Docker images
build:
	docker compose build

# Start services in background
up:
	docker compose up -d
	@echo ""
	@echo "✅ 서비스가 시작되었습니다!"
	@echo "   API: http://localhost:8080"
	@echo "   Health: http://localhost:8080/health"
	@echo ""
	@echo "로그 확인: make logs"

# Start services with logs
up-logs:
	docker compose up

# Stop services
down:
	docker compose down
	@echo "서비스가 중지되었습니다."

# Restart services
restart:
	docker compose restart
	@echo "서비스가 재시작되었습니다."

# View all logs
logs:
	docker compose logs -f

# View API logs only
logs-api:
	docker compose logs -f api

# View DB logs only
logs-db:
	docker compose logs -f db

# Show running containers
ps:
	docker compose ps

# Clean everything including volumes
clean:
	@echo "⚠️  모든 데이터가 삭제됩니다!"
	@read -p "계속하시겠습니까? (y/N) " confirm && [ "$$confirm" = "y" ]
	docker compose down -v --rmi local
	@echo "모든 리소스가 삭제되었습니다."

# Access PostgreSQL shell
db-shell:
	docker compose exec db psql -U tungjang -d tungjang_hero

# Access API container shell
api-shell:
	docker compose exec api sh

# Health check
health:
	@curl -s http://localhost:8080/health | jq . || curl -s http://localhost:8080/health

# Development: rebuild and restart
dev:
	docker compose down
	docker compose build --no-cache
	docker compose up -d
	@echo "개발 모드로 재시작되었습니다."

# Production build
prod:
	GIN_MODE=release docker compose up -d --build
	@echo "프로덕션 모드로 시작되었습니다."
