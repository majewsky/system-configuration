#include "entry.h"

#include <cstdlib>
#include <QtCore/QDir>
#include <QtCore/QProcess>
#include <QtCore/QVariant>
#include <QtWidgets/QMessageBox>
#include <QtWidgets/QPushButton>

Entry::Entry(const QString& declaration)
    : m_command(declaration)
{
    const QChar colon(':');
    if (m_command.contains(colon)) {
        QStringList parts = m_command.split(colon);
        m_shortcut = parts.takeFirst();
        m_command = parts.join(colon);
    }
}

QVector<Entry> Entry::list() {
    QFile file(QDir::home().filePath(".devenv/quickstartrc"));
    if (!file.open(QIODevice::ReadOnly)) {
        QMessageBox::critical(0,
            QStringLiteral("quickstart"),
            QStringLiteral("Cannot find quickstartrc")
        );
        exit(0);
    }

    const QByteArray data = file.readAll();
    QVector<Entry> result;
    for (const QByteArray& line: data.split('\n')) {
        if (line.isEmpty()) {
            continue;
        }
        result << Entry(QString::fromUtf8(line));
    }

    return result;
}

bool Entry::isValid() const {
    //try to find the m_command executable in the $PATH
    for (const QByteArray& path: qgetenv("PATH").split(':')) {
        const QDir pathDir(QString::fromLocal8Bit(path));
        const QFileInfo fi(pathDir, m_command);
        if (fi.isFile() && fi.isExecutable()) {
            return true;
        }
    }
    return false;
}

QPushButton* Entry::toButton() const {
    QPushButton* btn = new QPushButton(m_command);
    btn->setProperty("qs-shortcut", m_shortcut);

    const QString command = m_command;
    QObject::connect(btn, &QAbstractButton::clicked, [command, btn]() {
        if (!QProcess::startDetached(command, QStringList(), QDir::homePath())) {
            QMessageBox::critical(0,
                QStringLiteral("quickstart"),
                QStringLiteral("Failed to start %1").arg(command)
            );
        }
        btn->window()->hide();
    });

    return btn;
}
