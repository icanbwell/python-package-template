# Stage 1: Install production dependencies only.
FROM 856965016623.dkr.ecr.us-east-1.amazonaws.com/root-mirror/python:3.12-alpine3.20 AS python_packages

# Set terminal width (COLUMNS) and height (LINES)
ENV COLUMNS=300

# Set to true (via --build-arg) to (re)generate uv.lock instead of trusting an existing one.
# Used by `make lock` to bootstrap uv.lock on a fresh checkout, or to refresh it.
ARG RUN_UV_LOCK=false

# Install common tools and dependencies (git is required for some Python packages)
RUN apk add --no-cache git

# Install uv, a fast Python package manager
COPY --from=ghcr.io/astral-sh/uv:0.12.13@sha256:b485bd65cc2cf1c9a93b3554012c9c3778cf7b1b5fd3d3096ce9e1226c97e1e6 /uv /uvx /usr/local/bin/

# Set the working directory inside the container
WORKDIR /usr/src/{{cookiecutter.project_slug}}/

# Copy dependency files. uv.lock* (glob) tolerates a missing lockfile on a fresh checkout.
COPY pyproject.toml uv.lock* /usr/src/{{cookiecutter.project_slug}}/

# Regenerate uv.lock when asked to (fresh checkout or explicit refresh), then install
# production dependencies only into the system Python (no virtualenv, no dev group --
# pytest/mypy/ruff/bandit/twine stay out of this stage and everything built from it).
# `uv sync` has no --system flag (it always manages a project venv), so we go through
# `uv export` + `uv pip install --system` instead.
# --frozen uses the lockfile as-is without updating it.
RUN if [ "$RUN_UV_LOCK" = "true" ]; then rm -f uv.lock && uv lock; fi && \
    uv export --frozen --no-emit-project --no-dev -o /tmp/requirements.txt && \
    uv pip install --system -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# Expose the (possibly just-generated) lockfile so `make lock` can copy it back to the host.
RUN cp -f uv.lock /tmp/uv.lock

# Create necessary directories and list their contents (for debugging and verification)
RUN mkdir -p /usr/local/lib/python3.12/site-packages && ls -halt /usr/local/lib/python3.12/site-packages
RUN mkdir -p /usr/local/bin && ls -halt /usr/local/bin

# Check and print system and Python platform information (for debugging)
RUN python -c "import platform; print(platform.platform()); print(platform.architecture())"
RUN python -c "import sys; print(sys.platform, sys.version, sys.maxsize > 2**32)"

# Debug pip installation and list installed packages with verbosity
RUN uv pip list

# Stage 2: Add the dev dependency group (pytest, mypy, ruff, bandit, twine, pre-commit) on
# top of the production install. Only consumed by the `development` stage below.
FROM python_packages AS python_packages_dev

RUN uv export --frozen --no-emit-project --group dev -o /tmp/requirements.txt && \
    uv pip install --system -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# Stage 3: Production runtime image -- ships only what the `python_packages` stage
# installed, never the dev dependency group.
FROM 856965016623.dkr.ecr.us-east-1.amazonaws.com/root-mirror/python:3.12-alpine3.20 AS production

# Set terminal width (COLUMNS) and height (LINES)
ENV COLUMNS=300

# Install common tools and dependencies (git is required for some Python packages)
RUN apk add --no-cache git

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.12.13@sha256:b485bd65cc2cf1c9a93b3554012c9c3778cf7b1b5fd3d3096ce9e1226c97e1e6 /uv /uvx /usr/local/bin/

# Set environment variables for project configuration
ENV PROJECT_DIR=/usr/src/{{cookiecutter.project_slug}}
ENV FLASK_APP={{cookiecutter.project_slug}}.api
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus

# Create the directory for Prometheus metrics
RUN mkdir -p ${PROMETHEUS_MULTIPROC_DIR}

# Set the working directory for the project
WORKDIR ${PROJECT_DIR}

# Copy dependency files into the runtime image
COPY pyproject.toml uv.lock* ${PROJECT_DIR}/

# Copy installed Python packages from the production-only stage
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

# Stage 4: Development image -- production plus the dev tooling, used by docker-compose
# for local dev/test/pre-commit workflows. Not the default build target (see below).
FROM production AS development

USER root
COPY --from=python_packages_dev /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=python_packages_dev /usr/local/bin /usr/local/bin
RUN chown -R appuser:appgroup /usr/local/lib/python3.12/site-packages /usr/local/bin
USER appuser

# Final stage, re-declared so that `docker build .` with no --target defaults to
# production, not development (which is the last stage physically defined above).
FROM production
