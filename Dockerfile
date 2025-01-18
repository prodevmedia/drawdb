# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

# Stage 1: Build the app
FROM node:20-alpine AS build
ARG VITE_GITHUB_ACCESS_TOKEN

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

ENV VITE_GITHUB_ACCESS_TOKEN=${VITE_GITHUB_ACCESS_TOKEN}
RUN npm run build

# Stage 2: Setup the Nginx Server to serve the app
FROM nginx:stable-alpine3.17 AS production
COPY --from=build /app/dist /usr/share/nginx/html
RUN echo 'server { listen 80; server_name _; root /usr/share/nginx/html;  location / { try_files $uri /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]