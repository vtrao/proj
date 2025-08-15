FROM node:18-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build


FROM nginx:alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf


RUN mkdir -p /tmp && chmod 1777 /tmp \
    && mkdir -p /var/cache/nginx \
    && chmod 777 /var/cache/nginx \
    && chown -R appuser:appgroup /usr/share/nginx/html
USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD wget --spider -q http://localhost/ || exit 1

# Set filesystem to read-only except for /tmp
VOLUME ["/tmp"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]

