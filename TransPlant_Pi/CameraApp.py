import cv2
import numpy as np
from flask import Flask, render_template, Response

app = Flask(__name__)

def gen_frames():
    camera = cv2.VideoCapture(0)  # Use 0 for the default USB camera, you can change it if you have multiple cameras.
    while True:
        success, frame = camera.read()  # Read a frame from the camera
        if not success:
            break
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # Stream the frame as MJPEG
    camera.release()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
