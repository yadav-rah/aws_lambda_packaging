#!/bin/sh
set -e

copy_lambda_file() {
    LAMBDA_SOURCE=$1
    LAMBDA_PACKAGE_NAME=$2
    LAMBDA_FUNC_FOLDER=$LAMBDA_SOURCE
    if [ ! -d $LAMBDA_FUNC_FOLDER ]; then
        echo "No lambda function found! Make sure to create a file with the name 'lambda_function'."
        exit 1
    fi
    cp -a $LAMBDA_FUNC_FOLDER/. $LAMBDA_PACKAGE_NAME
}

delete_temp_files() {
    LAMBDA_PACKAGE_NAME=$1
    KEEP_ORIGINAL=$2
    # Removing files which are not required.
    cd $LAMBDA_PACKAGE_NAME
    # Removes packa metadata.
    echo "Removing packages metadata...!"
    find . -type d -name "*dist-info*" -exec rm -rf {} +
    cd ..
    rm -f requirements.txt
    if [ ! -z $KEEP_ORIGINAL ] && [ $KEEP_ORIGINAL = true ]; then
        echo "Keeping original package folder...!"
    else
        echo "Removing original package folder...!"
        rm -rf $LAMBDA_PACKAGE_NAME
    fi
}

install_requirements() {
    LAMBDA_SOURCE=$1
    LAMBDA_PACKAGE_NAME=$2
    PYTHON_VERSION=$3
    if [ -z $PYTHON_VERSION ]; then
        PYTHON_VERSION="2.7.0"
    fi
    REQUIREMENTS_FILE="$LAMBDA_SOURCE/requirements.txt"
    if [ ! -f $REQUIREMENTS_FILE ]; then
        echo "No requirements.txt found! Only Packaging Lambda Function"
    else
        if [ -f ./requirements.txt ]; then
            echo "Removing existing requirements.txt....!!!"
            rm -f ./requirements.txt
        fi
        echo "Copying requirement localy..!!"
        cp $REQUIREMENTS_FILE .
        # Docker Stuff
        echo "Installing packages from requirements.txt"
        docker build --build-arg PY_VER=$PYTHON_VERSION -t $LAMBDA_PACKAGE_NAME .
        TEMP_NAME="CON"
        CONTAINER_NAME="$LAMBDA_PACKAGE_NAME$TEMP_NAME"
        docker run --name=$CONTAINER_NAME $LAMBDA_PACKAGE_NAME
        docker cp $CONTAINER_NAME:/app/lib/. $LAMBDA_PACKAGE_NAME
        docker rm $CONTAINER_NAME
    fi
}

create_from_scratch() {
    LAMBDA_SOURCE=$1
    LAMBDA_PACKAGE_NAME=$2
    PYTHON_VERSION=$3
    if [ -d $LAMBDA_PACKAGE_NAME ]; then
        rm -r $LAMBDA_PACKAGE_NAME
    fi
    mkdir $LAMBDA_PACKAGE_NAME
    install_requirements $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME $PYTHON_VERSION
    copy_lambda_file $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME
}

replace_lambda() {
    LAMBDA_SOURCE=$1
    LAMBDA_PACKAGE_NAME=$2
    PYTHON_VERSION=$3
    KEEP_ORIGINAL=$4
    if [ ! -d $LAMBDA_PACKAGE_NAME ]; then
        echo "No previously created package found! Creating from scratch!"
        create_from_scratch $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME
        zip_package $LAMBDA_PACKAGE_NAME $KEEP_ORIGINAL
        exit 0
    fi
    LAMBDA_LAMBDA_PACKAGE_NAME_FOLDER=$LAMBDA_PACKAGE_NAME
    if [ -f $LAMBDA_LAMBDA_PACKAGE_NAME_FOLDER ]; then
        rm $LAMBDA_LAMBDA_PACKAGE_NAME_FOLDER
    fi
    copy_lambda_file $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME $PYTHON_VERSION
}

zip_package() {
    LAMBDA_PACKAGE_NAME=$1
    KEEP_ORIGINAL=$2
    PACKAGE_NAME="$LAMBDA_PACKAGE_NAME"
    ZIPPED_PACKAGE="$PACKAGE_NAME.zip"
    if [ -f $ZIPPED_PACKAGE ]; then
        echo "Previously created zipped package found! Removing the package!"
        rm $ZIPPED_PACKAGE
    fi
    cd $PACKAGE_NAME
    zip -r ../$ZIPPED_PACKAGE .
    cd ..
    echo "Calling Delete file function...!!"
    delete_temp_files $LAMBDA_PACKAGE_NAME $KEEP_ORIGINAL
}

for i in "$@"
do
case $i in
    -s=*|--source=*)
    LAMBDA_SOURCE="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--name=*)
    LAMBDA_PACKAGE_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--build=*)
    COMPLETE_BUILD="${i#*=}"
    shift # past argument=value
    ;;
    -v=*|--python_version=*)
    PYTHON_VERSION="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--keep_original=*)
    KEEP_ORIGINAL="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done
echo "Python Version is : $PYTHON_VERSION"
if [ -z $LAMBDA_SOURCE ] || [ -z $LAMBDA_PACKAGE_NAME ]; then
    echo "Enter the relative path to the directory containing the lambda function and the name of the function."
    exit 1
fi
if [ ! -z $COMPLETE_BUILD ] && [ $COMPLETE_BUILD = true ]; then
    echo "Creating package from scratch...!!"
    create_from_scratch $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME $PYTHON_VERSION
else
    echo "Trying to replace exiting lambda..!!"
    replace_lambda $LAMBDA_SOURCE $LAMBDA_PACKAGE_NAME $PYTHON_VERSION $KEEP_ORIGINAL
fi
zip_package $LAMBDA_PACKAGE_NAME $KEEP_ORIGINAL
