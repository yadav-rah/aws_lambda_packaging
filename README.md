# Creating a deployment package for lambda functions.

To create a Lambda function, you first create a lambda function deployment package, a .zip file consisting of your code and any dependencies. `generate_lambda_package.sh` can be used to generate a deployment package.

#### USAGE:
```sh
$ cd <scripts_dir>
$ ./generate_lambda_package.sh -s=<SOURCE_PACKAGE_RELATIVE_PATH> -n=<LAMBDA_FUNCTION_PACKAGE_NAME> -b=<BUILD> -v=<PYTHON_VERSION> -o=<ORIGINAL_FILES>
```

##### OPTIONS:
* -s (--source): The relative path to the directory containing the lambda function.
Note: Make sure that the directory contains a python file with the name *lambda_function.py* which contains the lambda function code.
* -n (--name): The name of the package that needs to be created.
* -b (--build) *(optional)*: A boolean indicating whether the package needs to be built from scratch. By default, the package will leave out the dependencies and copy over only the lambda function. Set this to `true` to re-create all the dependencies. The dependent packages are generated based on the *requirements.txt* file present in the source directory.
* -v (--python_version) *(optional)*: The python version to be used while installing the dependent packages. Defaults to `python 2.7.0`.
* -o (--keep_original) *(optional)*: A boolean indicating whether the original package folder to be stored. By default, the original package folder will be removed and only zip of original folder is saved. Set this to `true` to keep original folder.

#### IMPORTANT NOTES:
* Currently, the packaging script have support for python 2.7.0, 3.5.0, 3.6.0 & 3.7.0.
