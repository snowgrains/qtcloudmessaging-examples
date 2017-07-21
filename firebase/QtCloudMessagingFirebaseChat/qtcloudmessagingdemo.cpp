#include "qtcloudmessagingdemo.h"

qtcloudmessagingdemo::qtcloudmessagingdemo(QObject *parent) : QObject(parent)
{

}
void qtcloudmessagingdemo::startService(){

    m_qtCM = new QCloudMessaging();

    //! Add Google Firebase provider.
    m_firebaseService = new QCloudMessagingFirebaseProvider();


    QVariantMap params;

    //! Server API key is not recommended to store inside to the application code due security reasons.
    //! But if you do, make sure it is inside compiled C file or if you are doing a server side implementation with C++ & Qt.
    //!
    //! SERVER_API_KEY Is needed in this demo to be able to send topic messages from the client without Firebase application server.
    params["SERVER_API_KEY"] = "";

    //! Registering the Google firebase service component.
    m_qtCM->qRegisterProvider("GoogleFireBase",m_firebaseService,&params);

    /*! Connected client is needed for mobile device.
      \param Service name "GoogleFireBase"
      \param Client identifier name to be used inside the demo application
      \param Parameters for the client. Not used at this point.
    */
    m_qtCM->qConnectClient("GoogleFireBase","MobileClient", QVariantMap());

    //! Automatically subscribe to listen one topic on this demo.
    m_qtCM->qSubsribeToChannel("ChatRoom","GoogleFireBase","MobileClient");

}
