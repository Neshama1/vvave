#include "tracksmodel.h"
#include "db/collectionDB.h"


TracksModel::TracksModel(QObject *parent) : BaseList(parent)
{
    this->db = CollectionDB::getInstance();
    connect(this, &TracksModel::queryChanged, this, &TracksModel::setList);
}

FMH::MODEL_LIST TracksModel::items() const
{
    return this->list;
}

void TracksModel::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting query"<< this->query;

    emit this->queryChanged();
}

QString TracksModel::getQuery() const
{
    return this->query;
}

void TracksModel::setSortBy(const SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    this->preListChanged();
    this->sortList();
    this->postListChanged();
    emit this->sortByChanged();
}

TracksModel::SORTBY TracksModel::getSortBy() const
{
    return this->sort;
}

void TracksModel::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {
        case FMH::MODEL_KEY::RELEASEDATE:
        case FMH::MODEL_KEY::RATE:
        case FMH::MODEL_KEY::FAV:
        {
            if(e1[role].toDouble() > e2[role].toDouble())
                return true;
            break;
        }

        case FMH::MODEL_KEY::ADDDATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::TITLE:
        case FMH::MODEL_KEY::ARTIST:
        case FMH::MODEL_KEY::ALBUM:
        case FMH::MODEL_KEY::FORMAT:
        {
            const auto str1 = QString(e1[role]).toLower();
            const auto str2 = QString(e2[role]).toLower();

            if(str1 < str2)
                return true;
            break;
        }

        default:
            if(e1[role] < e2[role])
                return true;
        }

        return false;
    });
}

void TracksModel::setList()
{
    emit this->preListChanged();

    this->list = this->db->getDBData(this->query);

    qDebug()<< "my LIST" ;
    this->sortList();
    emit this->postListChanged();
}

QVariantMap TracksModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto item = this->list.at(index);

    for(auto key : item.keys())
        res.insert(FMH::MODEL_NAME[key], item[key]);

    return res;
}

void TracksModel::append(const QVariantMap &item)
{
    if(item.isEmpty())
        return;

    emit this->preItemAppended();

    FMH::MODEL model;
    for(auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    this->list << model;

    emit this->postItemAppended();
}

void TracksModel::append(const QVariantMap &item, const int &at)
{
    if(item.isEmpty())
        return;

    if(at > this->list.size() || at < 0)
        return;

    qDebug()<< "trying to append at" << at << item["title"];

    emit this->preItemAppendedAt(at);

    FMH::MODEL model;
    for(auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    this->list.insert(at, model);

    emit this->postItemAppended();
}

bool TracksModel::color(const int &index, const QString &color)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->colorTagTrack(item[FMH::MODEL_KEY::URL], color))
    {
        this->list[index][FMH::MODEL_KEY::COLOR] = color;
        emit this->updateModel(index, {FMH::MODEL_KEY::COLOR});
        return true;
    }

    return false;
}

bool TracksModel::fav(const int &index, const bool &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->favTrack(item[FMH::MODEL_KEY::URL], value))
    {
        this->list[index][FMH::MODEL_KEY::FAV] = value ?  "1" : "0";
        emit this->updateModel(index, {FMH::MODEL_KEY::FAV});

        return true;
    }

    return false;
}
