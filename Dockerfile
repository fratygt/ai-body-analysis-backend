# Use latest Flutter Docker image
FROM ghcr.io/cirruslabs/flutter:latest

# Set working directory
WORKDIR /app

# Copy pubspec files first (for better caching)
COPY pubspec.yaml pubspec.lock ./

# Upgrade Dart SDK & Install Dependencies
RUN flutter --version
RUN flutter doctor
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Expose the Flask API port (if using Flask for backend)
EXPOSE 5000

# Start the backend service
CMD ["dart", "ai_backend.py"]
