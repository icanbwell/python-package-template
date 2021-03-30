FROM python:3.7-slim
# https://github.com/imranq2/docker.spark_python
USER root

COPY Pipfile* /src/
WORKDIR /src

RUN pipenv sync --dev --system

COPY .. /src

# run pre-commit once so it installs all the hooks and subsequent runs are fast
RUN pre-commit install

# USER 1001
