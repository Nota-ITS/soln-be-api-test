#!/bin/bash

# 설정
REPO_DIR="/home/itsdev/workspace/soln-be-api-test"  # Git 저장소 경로
IMAGE_NAME="my_flask_app"      # Docker 이미지 이름
CONTAINER_NAME="my_flask_app"  # Docker 컨테이너 이름
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/webhook/url"  # Slack Webhook URL

# Slack 알림 함수
send_slack_notification() {
    # local message=$1
    # curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK_URL
    echo "success!!"
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

# Docker 이미지 생성
echo "Building Docker image..."
docker build -t $IMAGE_NAME . || handle_error "Failed to build Docker image"

# 기존 컨테이너 중지 및 삭제
echo "Stopping and removing existing container..."
docker stop $CONTAINER_NAME || handle_error "Failed to stop Docker container"
docker rm $CONTAINER_NAME || handle_error "Failed to remove Docker container"

# 새로운 컨테이너 실행
echo "Starting new container..."
docker run -d -p 5000:5000 --name $CONTAINER_NAME $IMAGE_NAME || handle_error "Failed to start Docker container"

# 성공 알림 전송
send_slack_notification "Deployment completed successfully!"

echo "Done."