# Stage 1: Build the application
FROM maven:3.8.5-openjdk-11 AS builder

# Install necessary packages including wget, gnupg, curl, and unzip
RUN apt-get update && \
    apt-get install -y wget gnupg2 curl unzip xvfb && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROME_DRIVER_VERSION=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -N https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip -P /tmp && \
    unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin/ && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /usr/local/bin/chromedriver

# Set display number for Xvfb
ENV DISPLAY=:99

# Set the working directory
WORKDIR /usr/src/app

# Copy project files
COPY . .

# Build the application
RUN mvn clean package -Pskip-Tests

# Verify the JAR file exists
RUN if [ -f /usr/src/app/target/your-app.jar ]; then \
    echo "File found"; \
else \
    echo "File not found"; exit 1; \
fi

# Stage 2: Run the application
FROM openjdk:11-jdk-slim

# Install necessary packages including wget, gnupg, curl, and unzip
RUN apt-get update && \
    apt-get install -y wget gnupg2 curl unzip xvfb && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROME_DRIVER_VERSION=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -N https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip -P /tmp && \
    unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin/