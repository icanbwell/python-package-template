# python-package-template
Cookiecutter template for creating a new Python Package

# Usage
1. Create a new github repo
2. Sync the github repo to your local machine.
3. `cd` into the folder
4. Run: ```docker run --rm -it -v $(pwd)/..:/app/ -w /app/ python:3.12 bash -c "mkdir -p cookiecutter; cd cookiecutter; pip install cookiecutter && cookiecutter https://github.com/icanbwell/python-package-template.git -v -f -o ../"```
6. This will ask you for the parameters.  Be sure to use your github repo name as the directory name
7. After generation is complete, run `make init` to set up your environment.
8. Run `make up` to bring up your environment in docker.
9. If using PyCharm, choose docker-compose as your interpreter and select the "dev" container.  Use the Virtualenv Environment option and set the Interpreter as `/usr/local/bin/python3`
10. For the first time publish to pypi, you will need to set a creator token:
  Run `export TWINE_PASSWORD=pypi-xxx` using the creator token
  Run `make package`.  This will create the new package in pypi.
  Login to pypi.org and create a token specific to this package.  Use that token below
12. To automate the publishing of the package, set the `PYPI` secret in your github repo to a pypi token.  We recommend you first set this to a pypi token that is scoped to all projects, create a release and then change the secret to a pypi token scoped to just this project.
