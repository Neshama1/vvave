#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QApplication>
#include "db/collectionDB.h"
#include "utils/bae.h"
#include "settings/settings.h"
#include "services/local/player.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();
    CollectionDB con;
    settings settings;
    Player player;

    context->setContextProperty("con", &con);
    context->setContextProperty("set", &settings);
    context->setContextProperty("player", &player);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
