from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import cv2
import mediapipe as mp

app = Flask(__name__)
CORS(app)  # Allow Flutter to communicate with this backend

# Initialize Mediapipe Pose model
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()

@app.route("/analyze", methods=["POST"])
def analyze_body():
    if "image" not in request.files or "height" not in request.form or "weight" not in request.form:
        return jsonify({"error": "Missing data"}), 400

    # Read the image
    file = request.files["image"]
    image_np = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # Read height & weight
    user_height_cm = float(request.form["height"])
    user_weight_kg = float(request.form["weight"])

    # Perform AI body analysis
    results = pose.process(image_rgb)

    if not results.pose_landmarks:
        return jsonify({"error": "No body detected"}), 400

    landmarks = results.pose_landmarks.landmark
    left_shoulder = np.array([landmarks[11].x, landmarks[11].y])
    right_shoulder = np.array([landmarks[12].x, landmarks[12].y])
    left_hip = np.array([landmarks[23].x, landmarks[23].y])
    right_hip = np.array([landmarks[24].x, landmarks[24].y])

    # Estimate body width (fat indicator)
    shoulder_width = np.linalg.norm(left_shoulder - right_shoulder)
    hip_width = np.linalg.norm(left_hip - right_hip)
    fat_factor = (hip_width + shoulder_width) / user_height_cm

    # Calculate BMI
    bmi = user_weight_kg / ((user_height_cm / 100) ** 2)

    # Generate AI fitness recommendation
    if bmi > 30 or fat_factor > 0.25:
        fitness_result = "You need to lose weight for a healthier body."
    elif 25 <= bmi < 30 or fat_factor > 0.20:
        fitness_result = "Your weight is slightly above average. Consider adjusting your diet and training."
    elif 18.5 <= bmi < 25 and fat_factor < 0.18:
        fitness_result = "You are in a healthy weight range. Maintain your current lifestyle."
    else:
        fitness_result = "You are below the average weight. Consider gaining weight for a healthier balance."

    return jsonify({"result": fitness_result})

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
