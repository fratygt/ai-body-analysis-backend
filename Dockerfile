# Use official Python image
FROM python:3.9

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y libgl1-mesa-glx

# Copy project files
COPY . .

# Install required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Expose the API port
EXPOSE 5000

# Run the backend
CMD ["python", "ai_backend.py"]
