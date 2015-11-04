# Docker images for opensnp.org

Currently two images - a *opensnp.org-docker* image and a *dev* image. The *opensnp.org-docker* image in the root folder pulls all gems and other dependencies. The *dev* image adds a few dummy files so that you can run the image in a local container.

# How to build the images

Start the docker server (screen/tmux/service if your system supports that)

    docker daemon

Then in the root folder:

    docker build -t opensnp.org-docker .

This builds the *opensnp.org-docker* image and sets the name to *opensnp.org-docker*. This step takes ~10 minutes since it installs all dependencies and gems.

Then to build the *dev* image:

    cd dev_image
    docker build -t dev .

To see all images:

    docker images

This should show two images, one named *opensnp.org-docker* and one named *dev*.

Now you can either build a container based on the *dev* image or on the *opensnp.org-docker* image.

# Building the dev container

    docker run dev

To run with environmental variables, in this case setting FOO to bar:

    docker run -e FOO=bar dev

