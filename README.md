# python-package-template
Cookiecutter template for creating a new Python Package

# Usage
1. Create a new GitHub repo (optionally with a README and license).
2. Clone the repo locally and `cd` into it.
3. Run Cookiecutter (Docker-based):
   ```bash
   docker run --rm -it -v $(pwd)/..:/app/ -w /app/ python:3.12 bash -c "mkdir -p cookiecutter; cd cookiecutter; pip install cookiecutter && cookiecutter https://github.com/icanbwell/python-package-template.git -v -f -o ../"
   ```
4. Answer the prompts. Use your GitHub repo name for the directory name.
5. If you see a permission error running pre-commit, run: `chmod +x ./.git/hooks/pre-commit`
6. After generation is complete:
   - `make init` to set up the local dev environment.
   - `make up` to bring up the Docker dev stack.
   - `make tests` to run tests in the dev container.
7. Packaging & publishing:
   - Set a token: `export TWINE_PASSWORD=pypi-xxx`
   - `make package` to publish to PyPI or `make testpackage` for TestPyPI.
   - Optionally configure a PyPI Trusted Publisher for GitHub Releases.
