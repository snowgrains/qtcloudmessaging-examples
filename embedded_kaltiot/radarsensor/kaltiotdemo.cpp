/* Copyright SnowGrains & Kaltiot Oy 2016, all rights reserved */

#include "kaltiotdemo.h"
#include <QVariantMap>
KaltiotDemo::KaltiotDemo(QObject *parent) : QObject(parent)
{

}
void KaltiotDemo::startService(){
    m_pushServices = new QCloudMessaging();
    m_kaltiotPushService = new QCloudMessagingEmbeddedKaltiotProvider();

    QVariantMap params;

    // Get the server API key via Kaltiot.com registration.
    params["API_KEY"] = "";

    m_pushServices->registerProvider("KaltiotService",m_kaltiotPushService, params);

    connect(m_pushServices, SIGNAL(messageReceived(QString,QString,QByteArray)), this, SIGNAL(pushMessageReceived(QString,QString,QByteArray)));

    QVariantMap params1;
    QVariantList channels;
    params1["address"] = "RadarSensor";
    params1["version"] = "0.1";
    channels.append("RadarChannel");
    params1["channels"] = channels;
    params1["customer_id"] = "Kaltiot";

    m_pushServices->connectClient("KaltiotService","RadarSensor",params1);

}

void KaltiotDemo::registerClient1(){


}



void KaltiotDemo::registerClient2(){
    QVariantMap params2;
    params2["address"] = "qtSensorTest2";
    params2["version"] = "0.1";
    params2["channel"] = "1";
    params2["customer_id"] = "sensor1";
    m_pushServices->connectClient("Service1","qtSensorTest2",params2);
}
void KaltiotDemo::closeAll(){
    m_pushServices->deregisterProvider("KaltiotService");
}


