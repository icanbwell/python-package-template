FROM 856965016623.dkr.ecr.us-east-1.amazonaws.com/root-mirror/python:3.12-alpine3.20

# Install git, build-essential, and uv
RUN apk add --no-cache git build-base
COPY --from=ghcr.io/astral-sh/uv:0.12.13@sha256:b485bd65cc2cf1c9a93b3554012c9c3778cf7b1b5fd3d3096ce9e1226c97e1e6 /uv /uvx /usr/local/bin/

# Copy dependency files. uv.lock* (glob) tolerates a missing lockfile -- run `make lock`
# (or `make init`) first on a fresh checkout so uv.lock exists before this builds.
COPY pyproject.toml uv.lock* ./

# Install dependencies into the system Python (no virtualenv). `uv sync` has no --system
# flag, so go through `uv export` + `uv pip install --system` instead.
RUN uv export --frozen --no-emit-project --group dev -o /tmp/requirements.txt && \
    uv pip install --system -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# Set the working directory
WORKDIR /sourcecode

# Clean up unnecessary files
RUN git config --global --add safe.directory /sourcecode

CMD ["pre-commit", "run", "--all-files"]