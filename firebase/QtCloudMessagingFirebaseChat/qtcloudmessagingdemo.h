/*!
  \brief Qt Cloud Messaging demo using Google's Firebase as service provider.
  \author Ari Salmi, SnowGrains. together with Kaltiot Oy.
  \copyright All rights reserved (c) SnowGrains & Kaltiot Oy 2017.
  \version: 1.0
*/

#ifndef QTCLOUDMESSAGINGDEMO_H
#define QTCLOUDMESSAGINGDEMO_H

#include <QObject>
#include <QCloudMessaging>
#include <QCloudMessagingFirebaseProvider>

class qtcloudmessagingdemo : public QObject
{
    Q_OBJECT
public:
    explicit qtcloudmessagingdemo(QObject *parent = 0);
    void startService();
    QCloudMessaging *getService() { return m_qtCM; }
signals:

public slots:
private:
    QCloudMessaging *m_qtCM;
    QCloudMessagingFirebaseProvider *m_firebaseService;
};

#endif // QTCLOUDMESSAGINGDEMO_H
