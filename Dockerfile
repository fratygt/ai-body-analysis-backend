# Use the official Python image
FROM python:3.9

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV & Mediapipe
RUN apt-get update && apt-get install -y libgl1-mesa-glx libglib2.0-0

# Copy project files
COPY . .

# Install required Python packages (including mediapipe)
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mediapipe

# Expose the API port
EXPOSE 5000

# Run the backend
CMD ["python", "ai_backend.py"]
