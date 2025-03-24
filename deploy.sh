#!/bin/bash

# 설정
# .env 파일 경로를 인자로 받음
ENV_FILE=$1

# .env 파일 로드
if [ -z "$ENV_FILE" ]; then
    echo "Usage: $0 path/to/.env"
    exit 1
fi

if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | xargs)
else
    echo ".env file not found at $ENV_FILE!"
    exit 1
fi

# Slack 알림 함수
send_slack_notification() {
    local message=$1
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK_URL
    # local message=$1
    # echo $message
}

# 오류 처리 함수
handle_error() {
    local message=$1
    send_slack_notification "$message"
    exit 1
}

# Git develop 브랜치 pull
echo "Pulling latest changes from develop branch..."
cd $REPO_DIR || handle_error "Failed to change directory to $REPO_DIR"
git checkout develop || handle_error "Failed to checkout develop branch"
git pull origin develop || handle_error "Failed to pull from develop branch"

# 현재 커밋 해시 가져오기
commit_hash=$(git rev-parse HEAD)

# Docker 이미지 생성
echo "Building Docker image..."
docker build -t $IMAGE_NAME $DOCKERFILE_PATH || handle_error "Failed to build Docker image"

# 기존 컨테이너 중지 및 삭제
echo "Stopping and removing existing container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# 새로운 컨테이너 실행
echo "Starting new container..."
docker run -d -p 5000:5000 --name $CONTAINER_NAME $IMAGE_NAME || handle_error "Failed to start Docker container"

# 성공 알림 전송
send_slack_notification "Deployment completed successfully!\nContainer: $CONTAINER_NAME\nCommit: $commit_hash"

echo "Done."