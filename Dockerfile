# syntax=docker/dockerfile:1

# Build frontend
FROM node:22-alpine AS frontend-build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --force

COPY . .
RUN npm run build

# Runtime
FROM python:3.11-slim-bookworm
WORKDIR /app/backend

# Install Python dependencies
COPY ./backend/requirements.txt ./
RUN pip install -r requirements.txt

# Copy application
COPY --from=frontend-build /app/build /app/build
COPY --from=frontend-build /app/CHANGELOG.md /app/CHANGELOG.md
COPY ./backend .

EXPOSE 8080

CMD ["python", "-m", "uvicorn", "open_webui.main:app", "--host", "0.0.0.0", "--port", "8080"]
