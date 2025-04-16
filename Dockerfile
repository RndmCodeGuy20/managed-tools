# Use an official Docker image as a base
FROM docker:latest

# Install docker-compose
RUN apk add --no-cache docker-compose

# Copy your docker-compose.yml file into the container
COPY docker-compose.yml /app/docker-compose.yml

# Set the working directory
WORKDIR /app

# Pull and run the images defined in docker-compose.yml
CMD ["docker-compose", "up"]