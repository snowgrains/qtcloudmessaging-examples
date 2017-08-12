/* Copyright SnowGrains & Kaltiot Oy 2016, all rights reserved */

#include "kaltiotdemo.h"
#include <QVariantMap>
KaltiotDemo::KaltiotDemo(QObject *parent) : QObject(parent)
{

}
void KaltiotDemo::startService(){
    m_pushServices = new QCloudMessaging();
    m_kaltiotPushService = new QCloudMessagingEmbeddedKaltiotProvider();

    QVariantMap paramss;
    paramss["API_KEY"] = "8riksUXIIbkQmG4Q1jeG5AniLjkd2xxhtGq8w15h2jMzQ3fpvwEcwUO2dQwE9%2BrP7ofGIRQheZgC9RyxeoDNq0fp4tpjSntLCYr05Yanb9I%3D";
    m_pushServices->registerProvider("KaltiotService",m_kaltiotPushService,paramss);

    connect(m_pushServices, SIGNAL(messageReceived(QString,QString,QString)), this, SIGNAL(pushMessageReceived(QString,QString,QString)));

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
    m_pushServices->deRegisterProvider("KaltiotService");
}


