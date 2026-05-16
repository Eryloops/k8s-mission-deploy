# Start from a minimal Alpine Linux image
FROM alpine:3.21

# Install the tools our script needs for system info
RUN apk add --no-cache procps iproute2

# Create a non-root user (security best practice)
RUN adduser -D -u 1000 mission

# Copy our script into the container
COPY mission.sh /mission.sh
RUN chmod +x /mission.sh

# Switch to the non-root user
USER mission

# Run the script when the container starts
ENTRYPOINT ["/mission.sh"]