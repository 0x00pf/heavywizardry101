# Heavy Wizardry 101 Official Repo

This is the official Repo for the book: Heavy Wizardry 101. You can find all the source code of the book organised by chapters


## Requirements

You need to install docker in your machine in order to install the development environment. 

## Development Environment 

The repository includes a Dockerfile that can be used to create a docker image with all the required images. 

To create the image execute:

```bash
$ ./build.sh
```

Once the image is created you can access the development environment running the script `start_env.sh`.

*NOTE: Execute the script from the repo root directory. The script makes all the source code available inside the docker container as a volume*

