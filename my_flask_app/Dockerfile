# 베이스 이미지로 Python 3.9 사용
FROM python:3.9-slim

# 작업 디렉토리 설정
WORKDIR /app

# 필요한 파일 복사
COPY requirements.txt requirements.txt
COPY main.py main.py

# 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt

# Flask 서버 실행
CMD ["python", "main.py"]

EXPOSE 5000
