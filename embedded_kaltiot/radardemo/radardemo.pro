

TEMPLATE = app
QT += qml quick

SOURCES += main.cpp \
    kaltiotdemo.cpp

HEADERS += \
    kaltiotdemo.h

RESOURCES += qml.qrc \
    images.qrc \
    fonts.qrc

# Check for KALTIOT_SDK environment
ENV_KALTIOT_SDK = $$(KALTIOT_SDK)

# Or define KALTIOT_SDK path here
KALTIOT_SDK =

isEmpty(ENV_KALTIOT_SDK) {
    isEmpty(KALTIOT_SDK) {
        message("KALTIOT_SDK" environment variable or define in radardemo.pro file not detected!)
    }
}


INCLUDEPATH += $$(KALTIOT_SDK)/src
INCLUDEPATH += $${KALTIOT_SDK}/src

QT += cloudmessagingembeddedkaltiot

# Default rules for deployment.
target.path = $$[QT_INSTALL_EXAMPLES]/cloudmessagingembeddedkaltiot/radardemo
INSTALLS += target

android: {
    DEFINES += ANDROID_OS
    QT += androidextras

    OTHER_FILES+=$$PWD/android/src/com/kaltiot/smartgatewayapi/KaltiotSmartGatewayApi.java \
                 $$PWD/android/src/com/kaltiot/smartgatewayapi/KaltiotSmartGatewayApiCallbacks.java \
                  $$PWD/android/src/com/snowgrains/radarsensor/QtApp.java \
                 $$PWD/android/src/com/snowgrains/radarsensor/KaltiotWrapper.java \
                 $$PWD/android/src/com/snowgrains/radarsensor/KaltiotService.java

    LIBS +=     $$PWD/android/libcrypto.so
    LIBS +=     $$PWD/android/libssl.so
    ANDROID_EXTRA_LIBS = \
        $$PWD/android/libcrypto.so \
        $$PWD/android/libssl.so

    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        info.plist

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    contains(ANDROID_TARGET_ARCH,armeabi-v7a) {

        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            item = item$${deploymentfolder}
            itemfiles = $${item}.files
            $$itemfiles = $$eval($${deploymentfolder}.source)
            itempath = $${item}.path
            $$itempath = /assets/$$eval($${deploymentfolder}.target)
            export($$itemfiles)
            export($$itempath)
            INSTALLS += $$item
        }
        export (INSTALLS)
    }
}
macos: {
    DEFINES += MAC_OS
     QMAKE_INFO_PLIST = $$PWD/Info.plist

}
