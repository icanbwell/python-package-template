# Copilot Code Review Instructions

## Objectives
- Keep changes aligned with this project's Python package template and its Docker-based dev workflow.
- Preserve linting, formatting, typing, and pre-commit rules.
- Avoid committing secrets and sensitive data.
- Provide direct, prioritized feedback with blockers first.

## Repository Context Summary
- **Stack**: Python 3.12, Docker, Docker Compose, Pipenv, pytest.
- **Key locations**:
  - `{{cookiecutter.project_slug}}/` – package source.
  - `tests/` – test suite.
  - `docker-compose.yml` – dev environment services.
  - `Makefile` – common commands (`make init`, `make up`, `make tests`, etc.).
- **Tooling**: pre-commit hook in `pre-commit-hook` and config in `setup.cfg`.

## Code Style and Quality Rules
- Prefer clear, explicit imports; avoid relative imports unless the project already uses them.
- Keep type annotations consistent with existing code style; avoid `Any` when a concrete type is available.
- Run `make run-pre-commit` before pushing changes.
- Follow the Makefile targets rather than ad-hoc commands when possible.

## Review Focus Areas (priority order)
1. **Security (blocking)**
   - Secrets or tokens must not be committed.
   - Avoid logging sensitive data.
2. **Correctness & Stability (blocking)**
   - Behavior matches requirements and avoids regressions.
   - Error handling is consistent with existing patterns.
3. **Quality & Style (blocking)**
   - Linting/formatting/type checks pass.
   - No unused or dead code introduced.
4. **Testing (blocking)**
   - New behavior has tests or is explicitly justified.
   - `make tests` remains green.
5. **Documentation (expected)**
   - Update `README.md` and docstrings when public behavior changes.

## Blocking Issues (must fix before merge)
- Secrets in code or docs.
- Failing lint/type/test checks.
- Regressions without test updates.
- Breaking the Docker-based dev workflow.

## Non-Blocking Suggestions (nice to have)
- Refactors that improve clarity or reduce complexity.
- Extra tests for edge cases.
- Documentation improvements.

## Security Guidelines
- Never commit credentials, tokens, or private keys.
- Prefer environment variables or `.env`/`docker.env` files that are gitignored.

## Testing Guidelines
- Use `make tests` for the canonical test run.
- Add unit tests under `tests/` for new logic.

## Dependencies & Build
- Manage dependencies via Pipenv.
- If `Pipfile` changes, regenerate `Pipfile.lock` using the Makefile target.

## Quick Start & Common Commands
- `make init` – set up the local dev environment.
- `make up` – start the Docker dev stack.
- `make tests` – run the test suite.
- `make shell` – open a shell in the dev container.

## Tone & Feedback Style
- Call out blockers first with file paths and line numbers.
- Keep feedback concise and actionable.
