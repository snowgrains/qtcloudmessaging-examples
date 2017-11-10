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
    m_pushServices->registerProvider("KaltiotService",m_kaltiotPushService,params);

    connect(m_pushServices, SIGNAL(messageReceived(QString,QString,QByteArray)), this, SIGNAL(messageReceived(QString,QString,QByteArray)));

    QVariantMap params1;
    params1["address"] = "RadarConsole";
    params1["version"] = "0.1";
    params1["customer_id"] = "Kaltiot";

    QVariantList channels;
    channels.append("RadarChannel");
    params1["channels"] = channels;
    m_pushServices->connectClient("KaltiotService","RadarConsole",params1);

}


void KaltiotDemo::closeAll(){
    m_pushServices->deregisterProvider("KaltiotService");
}


