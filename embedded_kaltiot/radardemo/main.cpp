/* Copyright SnowGrains & Kaltiot Oy 2016, all rights reserved */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <kaltiotdemo.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    KaltiotDemo *mdemo = new KaltiotDemo();

    mdemo->startService();

    // these are needed for keeping the received RID in memory after restart (in Android)
    QCoreApplication::setOrganizationName("Kaltiot2");
    QCoreApplication::setOrganizationDomain("kaltiot2.com");
    QCoreApplication::setApplicationName("RadarDemo2");

    engine.rootContext()->setContextProperty("m_demo", mdemo);
    engine.rootContext()->setContextProperty("m_pushServices", mdemo->getService());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
