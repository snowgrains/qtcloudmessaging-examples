
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QDebug>
#include "qtcloudmessagingdemo.h"


int main(int argc, char *argv[])
{

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    qtcloudmessagingdemo *m_qtcloud = new qtcloudmessagingdemo();

    m_qtcloud->startService();

    engine.rootContext()->setContextProperty("m_qtcloudmsg", m_qtcloud->getService());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));


    return app.exec();

}
