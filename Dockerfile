# Use Python image
FROM python:3.9

# Set working directory
WORKDIR /app

# Copy all files to container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose API port
EXPOSE 5000

# Run Flask API
CMD ["python", "ai_backend.py"]
