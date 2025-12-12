# python-package-template
Cookiecutter template for creating a new Python Package

# Usage
1. Create a new github repo (choose to create a readme.md and license if appropriate)
2. Sync the github repo to your local machine.
3. `cd` into the folder
4. Run: ```docker run --rm -it -v $(pwd)/..:/app/ -w /app/ python:3.12 bash -c "mkdir -p cookiecutter; cd cookiecutter; pip install cookiecutter && cookiecutter https://github.com/icanbwell/python-package-template.git -v -f -o ../"```
6. This will ask you for the parameters.  Be sure to use your github repo name as the directory name
7. If you get a permission error running pre-commit then run: `chmod +x ./.git/hooks/pre-commit`
8. After generation is complete, run `make init` to set up your environment.
9. Run `make up` to bring up your environment in docker.
10. If using PyCharm, choose docker-compose as your interpreter and select the "dev" container.  Use the System Environment option and set the Interpreter as `/usr/local/bin/python3`
11. For the first time publish to pypi, you will need to set a creator token:
  Run `export TWINE_PASSWORD=pypi-xxx` using the creator token
  Run `make package`.  This will create the new package in pypi.
12. Login to pypi.org and setup a Trusted Publisher relationship to your Github repo.  Now when you create a new release on github it will automatically publish to pypi.
