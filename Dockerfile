# Use the official LiteLLM image as base
FROM ghcr.io/berriai/litellm:main-stable

# Set working directory
WORKDIR /app

# Copy configuration file
COPY litellm-config.yaml /app/config.yaml

# Copy startup script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Install curl for health checks
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
USER 1001

# Expose the application port
EXPOSE 4000

# Use custom entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "8"]

