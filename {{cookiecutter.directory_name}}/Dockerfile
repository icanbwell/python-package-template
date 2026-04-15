# Stage 1: Base image to install common dependencies and lock Python dependencies
FROM public.ecr.aws/docker/library/python:3.12-alpine3.20 AS python_packages

# Set terminal width (COLUMNS) and height (LINES)
ENV COLUMNS=300

# Install common tools and dependencies (git is required for some Python packages)
RUN apk add --no-cache git

# Install uv, a fast Python package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Set the working directory inside the container
WORKDIR /usr/src/{{cookiecutter.project_slug}}/

# Copy dependency files
COPY pyproject.toml uv.lock /usr/src/{{cookiecutter.project_slug}}/

# Install all dependencies including dev group using uv
# --system installs into the system Python (no virtualenv)
# --frozen uses the lockfile as-is without updating it
RUN uv sync --group dev --system --frozen

# Create necessary directories and list their contents (for debugging and verification)
RUN mkdir -p /usr/local/lib/python3.12/site-packages && ls -halt /usr/local/lib/python3.12/site-packages
RUN mkdir -p /usr/local/bin && ls -halt /usr/local/bin

# Check and print system and Python platform information (for debugging)
RUN python -c "import platform; print(platform.platform()); print(platform.architecture())"
RUN python -c "import sys; print(sys.platform, sys.version, sys.maxsize > 2**32)"

# Debug pip installation and list installed packages with verbosity
RUN uv pip list

# Stage 2: Final runtime image for the application
FROM public.ecr.aws/docker/library/python:3.12-alpine3.20

# Set terminal width (COLUMNS) and height (LINES)
ENV COLUMNS=300

# Install common tools and dependencies (git is required for some Python packages)
RUN apk add --no-cache git

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Set environment variables for project configuration
ENV PROJECT_DIR=/usr/src/{{cookiecutter.project_slug}}
ENV FLASK_APP={{cookiecutter.project_slug}}.api
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus

# Create the directory for Prometheus metrics
RUN mkdir -p ${PROMETHEUS_MULTIPROC_DIR}

# Set the working directory for the project
WORKDIR ${PROJECT_DIR}

# Copy dependency files into the runtime image
COPY pyproject.toml uv.lock ${PROJECT_DIR}/

# Copy installed Python packages from the previous stage
COPY --from=python_packages /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=python_packages /usr/local/bin /usr/local/bin

# Copy the application code into the runtime image
COPY ./{{cookiecutter.project_slug}} ${PROJECT_DIR}

# Create directories and list their contents (for debugging and verification)
RUN mkdir -p /usr/local/lib/python3.12/site-packages && ls -halt /usr/local/lib/python3.12/site-packages
RUN mkdir -p /usr/local/bin && ls -halt /usr/local/bin

# Expose port 5000 for the application
EXPOSE 5000

# Switch to the root user to perform user management tasks
USER root

# Create a restricted user (appuser) and group (appgroup) for running the application
RUN addgroup -S appgroup && adduser -S -h /etc/appuser appuser -G appgroup

# Ensure that the appuser owns the application files and directories
RUN chown -R appuser:appgroup ${PROJECT_DIR} /usr/local/lib/python3.12/site-packages /usr/local/bin ${PROMETHEUS_MULTIPROC_DIR}

# Switch to the restricted user to enhance security
USER appuser