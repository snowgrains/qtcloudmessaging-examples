/* Copyright SnowGrains & Kaltiot Oy 2016, all rights reserved */

#ifndef KALTIOTDEMO_H
#define KALTIOTDEMO_H

#include <QObject>
#include <QByteArray>
#include <QtCloudMessagingEmbeddedKaltiot>

class KaltiotDemo : public QObject
{
    Q_OBJECT
public:
    explicit KaltiotDemo(QObject *parent = 0);
    Q_INVOKABLE void startService();

    Q_INVOKABLE void closeAll();
    QCloudMessaging *getService() { return m_pushServices; }
signals:
    void messageReceived(QString serviceID, QString clientID, QByteArray message);
public slots:
private:
    QCloudMessaging *m_pushServices;
    QCloudMessagingEmbeddedKaltiotProvider *m_kaltiotPushService;

};

#endif // KALTIOTDEMO_H
