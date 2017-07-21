TEMPLATE = app

QT += qml quick gui sql cloudmessagingfirebase
CONFIG += c++11


SOURCES += main.cpp \
    qtcloudmessagingdemo.cpp


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
target.path = $$[QT_INSTALL_EXAMPLES]/cloudmessagingfirebase/qtcloudmessagingfirebasechat
INSTALLS += target

# Check for GOOGLE_FIREBASE_SDK environment
ENV_FIREBASE_SDK = $$(GOOGLE_FIREBASE_SDK)

# Or define GOOGLE_FIREBASE_SDK path here
GOOGLE_FIREBASE_SDK =

isEmpty(ENV_FIREBASE_SDK) {
    ENV_FIREBASE_SDK = $${GOOGLE_FIREBASE_SDK}
    isEmpty(GOOGLE_FIREBASE_SDK) {
        message("GOOGLE_FIREBASE_SDK" environment variable or define in QtCloudMessagingFirebaseChat.pro file not detected!)
    }
}


INCLUDEPATH += $${ENV_FIREBASE_SDK}/include

android {
    message ("ANDROID Selected: Project dir: $$PWD, build dir: $$OUT_PWD")
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/src/com/snowgrains/kaltiot/qtgooglecloudmsg/TestappNativeActivity.java \
        android/src/com/snowgrains/kaltiot/qtgooglecloudmsg/LoggingUtils.java \
        android/google-services.json

    OTHER_FILES+= $$PWD/android/src/com/snowgrains/kaltiot/qtgooglecloudmsg/TestappNativeActivity.java \
                    $$PWD/android/src/com/snowgrains/kaltiot/qtgooglecloudmsg/LoggingUtils.java

}

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/android/lib/libssl.so \
        $$PWD/android/lib/libcrypto.so
}
macx:{
    #FIREBASE DUMMY LIBARY FOR DARWIN
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.12
    LIBS += -F$${ENV_FIREBASE_SDK}/frameworks/darwin \
      -framework firebase \
      -framework firebase_messaging
    QMAKE_INFO_PLIST +=$$PWD/ios/GoogleService-Info.plist

}
windows: {
    #FIREBASE LIBARY STUBS FOR CLOUD MESSAGING
    LIBS += $${ENV_FIREBASE_SDK}/libs/windows/libmessaging.a
    LIBS += $${ENV_FIREBASE_SDK}/libs/windows/libapp.a

}
ios:{
    # FIREBASE IOS LIBRARY
    # NOTE -
    # Linking firebase libraries straight does not work - it gives undefined symbols
    # therefore Cocoapods are needed and qmake generated xcode project file needs modification
    # See readme.txt
    TARGET= qtcloudmessagingfirebasechat
    QMAKE_INFO_PLIST =$$PWD/ios/Info.plist
    OTHER_FILES+= $$PWD/ios/Info.plist \
                  $$PWD/Podfile
    # REMEMBER TO ADD TO XCODE PROJECT
    HEADERS+= $$PWD/GoogleService-Info.plist
    QMAKE_IOS_DEPLOYMENT_TARGET = 7.0

    PRODUCT_BUNDLE_IDENTIFIER = com.snowgrains.kaltiot.qtgooglecloudmsg
    LIBS += \
      -F$${GOOGLE_FIREBASE_SDK}/frameworks/ios/arm64 \
      -framework firebase_messaging \
      -framework firebase
    LIBS += -framework Foundation
    LIBS += -framework UserNotifications
    LIBS += -framework UIKit
    LIBS += -framework CoreGraphics

}

HEADERS += \
    qtcloudmessagingdemo.h

DISTFILES += \
    readme.txt
