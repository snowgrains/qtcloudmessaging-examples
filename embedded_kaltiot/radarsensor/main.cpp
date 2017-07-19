/* Copyright SnowGrains & Kaltiot Oy 2016, all rights reserved */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <kaltiotdemo.h>
#include <QDebug>
#include <QStandardPaths>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    KaltiotDemo *mdemo = new KaltiotDemo();

    mdemo->startService();

    // these are needed for keeping the received RID in memory after restart (in Android)
    QCoreApplication::setOrganizationName("Kaltiot");
    QCoreApplication::setOrganizationDomain("kaltiot.com");
    QCoreApplication::setApplicationName("RadarSensor");

    QString app_folder = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    engine.setOfflineStoragePath(app_folder);


    engine.rootContext()->setContextProperty("m_demo", mdemo);
    engine.rootContext()->setContextProperty("m_pushServices", mdemo->getService());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
