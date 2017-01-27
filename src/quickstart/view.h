#ifndef QS_VIEW_H
#define QS_VIEW_H

#include <QtWidgets/QWidget>

class Entry;

class View : public QWidget {
    public:
        View();
        void setupButtons(const QVector<Entry>& entries);
    protected:
        virtual void focusOutEvent(QFocusEvent* event);
        virtual void keyPressEvent(QKeyEvent* event);
        virtual void paintEvent(QPaintEvent* event);
        virtual void showEvent(QShowEvent* event);
    private:
        QAction* m_action;
};

#endif // QS_VIEW_H
