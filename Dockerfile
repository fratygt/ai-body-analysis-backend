# Use a Flutter Docker image with the correct Dart version
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies first (caching layer)
COPY pubspec.yaml pubspec.lock ./
RUN flutter --version
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Expose Flask API port (adjust if needed)
EXPOSE 5000

# Run the backend script
CMD ["dart", "ai_backend.py"]
