#ifndef QS_ENTRY_H
#define QS_ENTRY_H

#include <QtCore/QString>
class QPushButton;

class Entry {
    public:
        Entry(const QString& declaration = QString());

        Entry(const Entry& other) = default;
        Entry(Entry&& other) = default;
        Entry& operator=(const Entry& other) = default;
        Entry& operator=(Entry&& other) = default;

        bool isValid() const;
        QPushButton* toButton() const;

        static QVector<Entry> list();
    private:
        QString m_shortcut, m_command;
};

#endif // QS_ENTRY_H
