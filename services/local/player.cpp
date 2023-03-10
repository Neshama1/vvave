/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#include "player.h"
#include "../../utils/bae.h"

#ifdef STATIC_MAUIKIT
#include "mauiaccounts.h"
#else
#include <mauiaccounts.h>
#endif

Player::Player(QObject *parent) : QObject(parent),
    player(new QMediaPlayer(this))
{ 
    updater= new QTimer(this);
    this->player->setVolume(this->volume);
    connect(this->updater, &QTimer::timeout, this, &Player::update);
}

inline QNetworkRequest getOcsRequest(const QNetworkRequest& request)
{
    QMap<QByteArray, QByteArray> rawHeaders;
    for (const QByteArray& headerKey : request.rawHeaderList()) {
        rawHeaders.insert(headerKey, request.rawHeader(headerKey));
    }

    const auto account = FMH::toModel(MauiAccounts::instance()->getCurrentAccount());
    const QString concatenated =  QString("%1:%2").arg(account[FMH::MODEL_KEY::USER], account[FMH::MODEL_KEY::PASSWORD]);
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const QString headerData = "Basic " + data;


    // Construct new QNetworkRequest with prepared header values
    QNetworkRequest newRequest(request);

    newRequest.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());
    newRequest.setRawHeader(QByteArrayLiteral("OCS-APIREQUEST"), QByteArrayLiteral("true"));
    newRequest.setRawHeader(QByteArrayLiteral("Cache-Control"), QByteArrayLiteral("public"));
    newRequest.setRawHeader(QByteArrayLiteral("Content-Description"), QByteArrayLiteral("File Transfer"));

    newRequest.setHeader(QNetworkRequest::ContentTypeHeader, "audio/mpeg");
    newRequest.setAttribute(QNetworkRequest::CacheSaveControlAttribute, true);
    newRequest.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    return newRequest;
}

bool Player::play()
{
    if(this->url.isEmpty()) return false;

    if(!updater->isActive())
        this->updater->start(200);

    this->player->play();
    return true;
}

void Player::pause()
{
    if(this->player->isAvailable()){
        this->player->pause();
    }
}

void Player::stop()
{
    if(this->player->isAvailable())
    {
        this->player->stop();
        this->url = QString();
        this->player->setMedia(QMediaContent());
    }

    this->playing = false;
    emit this->playingChanged();

    this->updater->stop();

    this->emitState();
}

void Player::emitState()
{
    switch(this->player->state())
    {
    case QMediaPlayer::PlayingState:
        this->state = Player::STATE::PLAYING;
        break;
    case QMediaPlayer::PausedState:
        this->state = Player::STATE::PAUSED;
        break;
    case QMediaPlayer::StoppedState:
        this->state = Player::STATE::STOPED;
        break;
    }

    emit this->stateChanged();
}

QString Player::transformTime(const int &pos)
{
    return BAE::transformTime(pos);
}

void Player::setUrl(const QUrl &value)
{
//    if(value == this->url)
//        return;

    this->url = value;
    emit this->urlChanged();

    this->pos = 0;
    emit this->posChanged();

    const auto media = this->url.isLocalFile() ? QMediaContent(this->url) : QMediaContent(getOcsRequest(QNetworkRequest(this->url)));

    this->player->setMedia(media);
    this->emitState();
}

QUrl Player::getUrl() const
{
    return this->url;
}

void Player::setVolume(const int &value)
{
    if(value == this->volume)
        return;

    this->volume = value;
    this->player->setVolume(volume);
    emit this->volumeChanged();
}

int Player::getVolume() const
{
    return this->volume;
}

double Player::getDuration() const
{
    return static_cast<double>(this->player->duration());
}

QMediaPlayer::State Player::getState() const
{
    return this->player->state();
}

Player::STATE Player::getPlayState() const
{
    return this->state;
}

void Player::setPlaying(const bool &value)
{
    this->playing = value;

    if(this->playing)
        this->play();
    else this->pause();

    emit this->playingChanged();
    this->emitState();
}

bool Player::getPlaying() const
{
    return this->playing;
}

bool Player::getFinished()
{
    return this->finished;
}

void Player::setPos(const double &value)
{
    this->pos = value;
    this->player->setPosition(this->player->duration() / 1000 * this->pos);
    this->emitState();
    this->posChanged();
}

double Player::getPos() const
{
    return this->pos;
}

qint64 Player::getPlayerPos()
{
    return player->position();
}

void Player::update()
{
    if(this->player->isAvailable())
    {
        if(this->player->duration() == 0)
        {
            return;
        }
        this->pos = static_cast<int>(static_cast<double>(this->player->position()) / this->player->duration() * 1000);
        emit this->durationChanged();
        emit this->posChanged();
    }

    if(this->player->state() == QMediaPlayer::StoppedState && this->updater->isActive() && this->player->position() == this->player->duration())
    {
        this->finished = true;
        emit this->finishedChanged();
    }

    this->emitState();
}
