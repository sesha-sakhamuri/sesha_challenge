FROM nginx:alpine

# Create directory for SSL certs
RUN mkdir -p /etc/ssl/private /etc/ssl/certs

# Update apk and install openssl
RUN apk update && apk add openssl

# Generate self-signed SSL cert
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/CN=localhost"

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the static website content
COPY index.html /usr/share/nginx/html/index.html

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Set the entrypoint or command for Nginx to run in the foreground
CMD ["nginx", "-g", "daemon off;"]
