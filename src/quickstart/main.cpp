#include "entry.h"
#include "view.h"

#include <QtWidgets/QApplication>

int main(int argc, char** argv) {
    QApplication app(argc, argv);

    app.setStyleSheet(QStringLiteral(
        "QPushButton { font-size: 24px; border: none; color:white; padding: 12px }"
        "QPushButton:hover, QPushButton:pressed { background: #666 }"
        "QPushButton:pressed { background: #CCC; color: black }"
    ));

    View view;
    view.setupButtons(Entry::list());

    return app.exec();
}
