# Use the latest Dart official image with the correct version
FROM dart:3.7.2

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Get dependencies
RUN dart pub get

# Expose the application port
EXPOSE 8080

# Run the server
CMD ["dart", "bin/server.dart"]
