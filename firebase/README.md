QT Cloud messaging firebase + own app installation instructions:


1. Download and unzip google firebase c++ SDK:
    https://firebase.google.com/docs/cpp/setup
    https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_3.1.2.zip

2. Set commmand line environment variable:
    GOOGLE_FIREBASE_SDK =
    and make it to point to your firebase sdk root

3. Install first the QtCloudMessagingfrom command line with:

    qmake (to desired qt platform)
    make
    make install

4. Add firebace console with firebase instructions and retrieve "GoogleService-Info.plist" and copy it to build directory
    Instructions to create firebase console:
    https://firebase.google.com/
    4.1 Download GoogleService-Info.plist

5. Open QtCloudMessagingFirebaseChat.pro
    5.1 Desktop build are using dummy firebase libraries. Desktop builds can be used to mimic e.g. firebase server for sending messages. This is included in this example.

    5.2 ANDROID: Just compile and run on android device.

    5.3  IOS: Ios version needs Cocoapods, and some tweaks to generated xcodeproject file.

        1. Copy Podfile (included in the example) to build directory with generated xcode project file
        2. run
            pod install

            --> you will get errors for few lines which are not regonized by cocoapods
            you will need to remove those line.

            So, open following file with text editor:
            QtCloudMessagingFirebaseChat.xcodeproj/project.pbxproj

            Remove all lines having:
            refType = 0;
            name = "Compile Sources";
            name = "Link Binary With Libraries";
            name = "Copy Bundle Resources";

            And you need to remove empty buildRules separated in two lines:
            buildRules = (
            );

            Also make sure the IOS development target is pointing at least to 7.0
            IPHONEOS_DEPLOYMENT_TARGET = "7.0"


            run then again:
            pod install

         3. You should get QtCloudMessagingFirebaseChat.xcworkspace - file.
            open workspace file with Xcode and run the app.
         4. Drag and drop GoogleService-Info.plist to xcode project.
         5. build and run

