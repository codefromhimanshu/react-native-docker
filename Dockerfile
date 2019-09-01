FROM openjdk:8-jdk


# ---------------------------
# --- Install required tools

#Installing Packages
RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1

# ---Installing the Android SDK
RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip
RUN unzip -d android-sdk-linux android-sdk.zip
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platform-tools" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null

RUN touch ~/.android/repositories.cfg
RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p
RUN sysctl --system


# ---Setting up the environment variable

RUN export ANDROID_HOME=$PWD/android-sdk-linux
RUN export PATH=$PATH:$PWD/android-sdk-linux/platform-tools/



# ---temporarily disable checking for EPIPE error and use yes to accept all licenses
RUN set +o pipefail
RUN yes | android-sdk-linux/tools/bin/sdkmanager --licenses # accept SDK licences
RUN set -o pipefail


RUN curl -sL https://deb.nodesource.com/setup_10.x | bash #Add Node Repo
RUN apt-get install -y nodejs #Install NOde JS
RUN npm install -g react-native-cli #Install React-Native CLI