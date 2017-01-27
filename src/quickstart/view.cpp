#include "view.h"
#include "entry.h"

#include <QtWidgets/QAction>
#include <QtGui/QFocusEvent>
#include <QtGui/QKeyEvent>
#include <QtGui/QPainter>
#include <QtWidgets/QApplication>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QPushButton>

#include <kglobalaccel.h>
#include <kwindowsystem.h>

View::View() {
    setWindowFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
    setAttribute(Qt::WA_DeleteOnClose, false);
    setAttribute(Qt::WA_MouseTracking); //TODO: necessary?
    setAttribute(Qt::WA_TranslucentBackground);
    setWindowState(Qt::WindowActive | Qt::WindowMaximized);
    KWindowSystem::self()->setOnAllDesktops(winId(), true);
    //TODO: prevent minimizing/maximizing
    //TODO: do not show on pager
    setFocusPolicy(Qt::StrongFocus);

    //setup the action that triggers this->show()
    m_action = new QAction(QStringLiteral("Show window"), this);
    m_action->setObjectName(QStringLiteral("show_window"));
    m_action->setProperty("componentName", "quickstart");
    m_action->setProperty("componentDisplayName", "QuickStart");
    connect(m_action, &QAction::triggered, this, &QWidget::show);
    KGlobalAccel::self()->setShortcut(m_action, QList<QKeySequence>() << QKeySequence(QStringLiteral("F13")));
}

void View::focusOutEvent(QFocusEvent* event) {
    if (event->reason() == Qt::ActiveWindowFocusReason) {
        hide();
    }
}

void View::keyPressEvent(QKeyEvent* event) {
    //hide on Escape
    if (event->key() == Qt::Key_Escape) {
        hide();
        event->accept();
    }

    //find if this key is registered as a shortcut (we cannot use the
    //QAbstractButton::shortcut functionality for this since it will insist on
    //adding an Alt modifier to the shortcut)
    const QString text = event->text();
    for (QObject* obj: children()) {
        if (QPushButton* btn = qobject_cast<QPushButton*>(obj)) {
            if (btn->property("qs-shortcut") == text) {
                btn->animateClick();
            }
        }
    }
}

void View::paintEvent(QPaintEvent* event) {
    Q_UNUSED(event)
    QColor bgColor(Qt::black);
    bgColor.setAlpha(192);
    QPainter(this).fillRect(rect(), bgColor);
}

void View::showEvent(QShowEvent* event) {
    Q_UNUSED(event)
    setFocus(Qt::OtherFocusReason);
    setWindowState(Qt::WindowActive | Qt::WindowMaximized);
}

void View::setupButtons(const QVector<Entry>& entries) {
    QGridLayout* layout = new QGridLayout(this);

    int entryCount = 0;
    for (const Entry& entry: entries) {
        if (entry.isValid()) {
            layout->addWidget(entry.toButton(), ++entryCount, 1);
        }
    }

    layout->setColumnStretch(0, 1);
    layout->setColumnStretch(2, 1);
    layout->setRowStretch(0, 1);
    layout->setRowStretch(entryCount + 1, 1);
}
