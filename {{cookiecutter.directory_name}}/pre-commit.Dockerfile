FROM python:3.12-alpine3.20

# Install git, build-essential, and pipenv
RUN apk add --no-cache git build-base && \
    pip install pipenv

# Copy Pipfile and Pipfile.lock
COPY Pipfile* ./

# Install dependencies using pipenv
RUN pipenv sync --dev --system

# Set the working directory
WORKDIR /sourcecode

# Clean up unnecessary files
RUN git config --global --add safe.directory /sourcecode

# Define the command to run
CMD ["sh", "-c", "if [ \"$PRE_COMMIT_ALL_FILES\" = true ] ; then pre-commit run --all-files ; else pre-commit run ; fi"]
