from flask import Flask, Response, request
import time
import queue
import threading

app = Flask(__name__)

# 이벤트를 저장할 큐
event_queue = queue.Queue()

@app.route('/')
def helloworld():
    return "Hello, World!s"

def generate_events():
    while True:
        # 큐에서 이벤트를 가져옴
        event_data = event_queue.get()
        yield f"data: {event_data}\n\n"

@app.route('/stream')
def stream():
    return Response(generate_events(), content_type='text/event-stream')

@app.route('/trigger_event', methods=['POST'])
def trigger_event():
    # 클라이언트로부터 이벤트 데이터를 받음
    event_data = request.form.get('data', 'No data')
    # 큐에 이벤트 데이터를 추가
    event_queue.put(event_data)
    return "Event triggered!", 200

if __name__ == '__main__':
    app.run(debug=True, threaded=False)