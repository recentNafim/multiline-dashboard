# MLIL Customer Dashboard: Flutter Web build + lightweight Nginx runtime.
# Fixed Flutter image tag: reproducible build, Dart compatible with pubspec.yaml.
FROM ghcr.io/cirruslabs/flutter:3.41.4 AS flutter-build
USER root
WORKDIR /app
ENV CI=true

# Restore dependencies first so Docker can cache this layer.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Include web/pptx_generator.js, model viewer setup, latest lib, and icons.
COPY . .

# Deploy at / on a standalone server (e.g. http://SERVER_IP:3701).
ARG FLUTTER_BASE_HREF=/
RUN flutter build web --release --base-href="${FLUTTER_BASE_HREF}"

FROM nginx:stable-alpine AS runtime
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=flutter-build /app/build/web/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1
