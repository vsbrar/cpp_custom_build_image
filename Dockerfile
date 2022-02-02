# base image
# Note here that we’re not building the entire aws-sdk-cpp.
# The -DBUILD_ONLY="s3;transfer" flag determines which packages you want to build. 
# You can customize this flag according to your application’s needs.
FROM public.ecr.aws/lts/ubuntu:18.04_stable
ENV DEBIAN_FRONTEND=noninteractive
# build as root
USER 0
# install required build tools via packet manager
RUN apt-get update -y && apt-get install -y ca-certificates curl build-essential git cmake libz-dev libssl-dev libcurl4-openssl-dev
# AWSCPPSDK we build s3 and transfer manager
RUN git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp \
    && mkdir sdk_build && cd sdk_build \
    && cmake ../aws-sdk-cpp/ -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY="s3;transfer" -DENABLE_TESTING=OFF -DBUILD_SHARED_LIBS=OFF \
    && make -j $(nproc) && make install \
    && cd .. \
    && rm -rf sdk_build
# finalize the build
WORKDIR /