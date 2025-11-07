# Use Ubuntu LTS as base
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash cron ca-certificates curl wget tar gzip coreutils procps \
      iproute2 grep sed gawk util-linux jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy scripts into image later (we’ll create them soon)
COPY ./scripts /workspace/scripts
COPY entrypoint.sh /workspace/entrypoint.sh

# Make scripts executable
RUN chmod +x /workspace/entrypoint.sh /workspace/scripts/*.sh || true

# Default entrypoint
ENTRYPOINT ["/workspace/entrypoint.sh"]



