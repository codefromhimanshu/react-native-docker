# RUN rm -f /etc/ssl/certs/java/cacerts; \
#   /var/lib/dpkg/info/ca-certificates-java.postinst configure


# RUN mkdir -p $ANDROID_HOME/licenses/ \
#   && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
#   && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28"

# ADD packages.txt /sdk
# RUN mkdir -p /root/.android && \
#   touch /root/.android/repositories.cfg && \
#   ${ANDROID_HOME}/tools/bin/sdkmanager --update

# RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
#   ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}



FROM ubuntu:20.04
LABEL maintainer="Himanshu Jain"

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-8512546_latest.zip
ARG ANDROID_BUILD_VERSION=33
ARG ANDROID_TOOLS_VERSION=33.0.0
ARG BUCK_VERSION=2022.05.05.01
ARG NDK_VERSION=23.1.7779620
ARG NODE_VERSION=16.x
ARG WATCHMAN_VERSION=4.9.0

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

# Install system dependencies
RUN apt-get -qq update
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
RUN apt update -qq && apt install -qq -y --no-install-recommends \
      apt-transport-https \
      bzip2 \
      curl \
      git-core \
      html2text \
      unzip \
      file \
      gcc \
      git \
      g++ \
      gnupg2 \
      libc++1-10 \
      libgl1 \
      libtcmalloc-minimal4 \
      make \
      openjdk-11-jdk-headless \
      openssh-client \
      patch \
      python3 \
      python3-distutils \
      rsync \
      ruby \
      ruby-dev \
      tzdata \
      unzip \
      sudo \
      ninja-build \
      zip \
      rubygems-integration \
      build-essential \
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# Removed these
  # libc6-i386 \
  # lib32stdc++6 \
  # lib32gcc1 \
  # lib32ncurses5 \
  # lib32z1 \


# install nodejs and yarn packages from nodesource
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs \
    && npm i -g yarn \
    && npm i -g react-native-cli \
    && rm -rf /var/lib/apt/lists/*

# install gems from source
RUN gem install bundler -v 1.17.2

# download and install buck using debian package
# RUN curl -sS -L https://github.com/facebook/buck/releases/download/v${BUCK_VERSION}/buck.${BUCK_VERSION}_all.deb -o /tmp/buck.deb \
#     && dpkg -i /tmp/buck.deb \
#     && rm /tmp/buck.deb

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
# workaround buck clang version detection by symlinking
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;3.18.1" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && ln -s ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8