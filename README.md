QT CLOUD MESSAGING API INSTALLATION:

1. To install with available backend add following to qmake script:
    qmake "CONFIG += embedded-kaltiot"
    of
    qmake "CONFIG += firebase"

    e.g.:
    qmake "CONFIG += embedded-kaltiot firebase"
    make
    make install

Google Firebase requirements:
2. Download and unzip google firebase c++ SDK:
    https://firebase.google.com/docs/cpp/setup
    https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_3.1.2.zip

3. To use firebase as backend define following ENVIRONMENT variable
    GOOGLE_FIREBASE_SDK =
    and make it to point to your firebase sdk root

Embedded-Kaltiot requirements:
4. To use in embedded Kaltiot backend:
    3.1. Register your app in
        https://console.torqhub.io/signin

    3.2. Download platform SDK from the console download page

    3.3. Add environment variable to pointing to downloaded and unzipped SDK root:
        KALTIOT_SDK = ../../../<yourappname>_RasperryPi_SDK_1.0.17


5. Install first the QtCloudMessagingfrom command line with:

    qmake "CONFIG += embedded-kaltiot firebase"
    make
    make install

6. Now you can use the QtCloudMessagingn in your app with

    Just API wrapper (e.g. creating new service providers)
    QT += cloudmessaging

    With Firebase backend:
    QT += cloudmessagingfirebase

    With Embedded devices & Kaltiot
    QT += cloudmessagingembeddedkaltiot

    See more from the example apps.

    To configure examples, set qmake "CONFIG += firebase-examples embedded-kaltiot-examples"
