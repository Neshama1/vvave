import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.Material 2.1

import "db/Queries.js" as Q
import "utils/Player.js" as Player
import "utils"
import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "view_models"

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: !isMobile ? wideSize : 400
    minimumWidth: !isMobile ? columnWidth : 0
    minimumHeight:  !isMobile ? columnWidth+64 : 0
    height: 500
    title: qsTr("Babe")
    wideScreen: root.width > coverSize

    Material.theme: Material.Light
    Material.accent: bae.babeColor()
    Material.background: bae.backgroundColor()
    Material.primary: bae.backgroundColor()
    Material.foreground: bae.foregroundColor()

    //    property int columnWidth: Kirigami.Units.gridUnit * 13

    readonly property bool isMobile: bae.isMobile()
    readonly property int maxW : root.maximumWidth
    readonly property int maxH : root.maximumHeight
    readonly property int wideSize : bae.screenGeometry("width")*0.45
    property int columnWidth: Kirigami.Units.gridUnit * 20
    property int coverSize: columnWidth*0.65
    //    property int columnWidth: Math.sqrt(root.width*root.height)*0.4
    property int currentView : 0
    property int toolBarIconSize: isMobile ?  24 : 22
    property alias mainPlaylist : mainPlaylist
    //    minimumWidth: columnWidth

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [mainPlaylist, views]
    pageStack.interactive: isMobile
    pageStack.separatorVisible: pageStack.wideMode
    //    overlay.modal: Rectangle
    //    {
    //        color: "transparent"
    //    }

    //    overlay.modeless: Rectangle
    //    {
    //        color: "transparent"
    //    }

    onWidthChanged: if(root.isMobile)
                    {
                        if(root.width>root.height)
                            mainPlaylist.cover.visible = false
                        else  mainPlaylist.cover.visible = true
                    }


    onClosing: Player.savePlaylist()

    function runSearch()
    {
        if(searchInput.text)
        {
            if(searchInput !== searchView.headerTitle)
            {
                var query = searchInput.text
                searchView.headerTitle = query
                var queries = query.split(",")
                searchView.searchRes = bae.searchFor(queries)

                searchView.populate(searchView.searchRes)
            }
            //                albumsView.filter(res)
            currentView = 4
            pageStack.currentIndex = 1
        }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchView.clearTable()
        searchView.headerTitle = ""
        searchView.searchRes = []
        currentView = 0
    }

    Connections
    {
        target: player
        onPos: mainPlaylist.progressBar.value = pos
        onTiming: mainPlaylist.progressTime.text = time
        onDurationChanged: mainPlaylist.durationTime.text = time
        onFinished: Player.nextTrack()
    }

    Connections
    {
        target: bae
        onRefreshTables:
        {
            tracksView.clearTable()
            albumsView.clearGrid()
            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }

        onTrackLyricsReady:
        {
            if(url === root.mainPlaylist.currentTrack.url)
                root.mainPlaylist.infoView.lyrics = lyrics
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()
    }

    header: BabeBar
    {
        id: mainToolbar
        visible: true
        size: toolBarIconSize
        currentIndex: currentView

        onPlaylistViewClicked:
        {
            if(!isMobile && pageStack.wideMode)
                root.width = columnWidth
            else root.width = wideSize


            pageStack.currentIndex = 0

        }
        onTracksViewClicked:
        {
            if(!isMobile && !pageStack.wideMode)
                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 0
        }
        onAlbumsViewClicked:
        {
            if(!isMobile && !pageStack.wideMode)
                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 1
        }
        onArtistsViewClicked:
        {
            if(!isMobile && !pageStack.wideMode)
                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 2
        }
        onPlaylistsViewClicked:
        {
            if(!isMobile && !pageStack.wideMode)
                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 3
        }
        onSettingsViewClicked: settingsDrawer.visible ? settingsDrawer.close() : settingsDrawer.open()
    }

    footer: Rectangle
    {
        id: searchBox
        width: parent.width
        height: 48
        color: searchInput.activeFocus ? bae.midColor() : bae.midLightColor()
        Kirigami.Separator
        {
            Rectangle
            {
                anchors.fill: parent
                color: Kirigami.Theme.viewFocusColor
            }

            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }

        TextInput
        {
            id: searchInput
            anchors.fill: parent
            anchors.centerIn: parent
            color: bae.foregroundColor()
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            selectByMouse: !root.isMobile
            selectionColor: bae.hightlightColor()
            selectedTextColor: bae.foregroundColor()
            property string placeholderText: "Search..."

            onAccepted: runSearch()

            BabeButton
            {
                id: searchBtn
                anchors.centerIn: parent
                visible: !(searchInput.focus || searchInput.text)

                iconName: "edit-find" //"search"
                onClicked:
                {
                    searchInput.forceActiveFocus()

                }
            }


            BabeButton
            {
                anchors.right: parent.right
                visible: searchInput.activeFocus
                iconName: "edit-clear"
                onClicked: clearSearch()
            }


        }


    }

    background: Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    SettingsView
    {
        id: settingsDrawer
        onIconSizeChanged: toolBarIconSize = (size === 24 && isMobile) ? 24 : 22
    }



    MainPlaylist
    {
        id: mainPlaylist
        Connections
        {
            target: mainPlaylist
            onCoverPressed: Player.appendAll(tracks)
            onCoverDoubleClicked: Player.playAll(tracks)
        }

    }

    Page
    {
        id: views
        anchors.fill: parent
        clip: true

        //        transform: Translate {
        //            x: (settingsDrawer.position * views.width * 0.33)*-1
        //        }

        Column
        {
            width: parent.width
            height: parent.height

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height

                Component.onCompleted: contentItem.interactive = root.isMobile

                currentIndex: currentView

                onCurrentItemChanged:
                {
                    currentItem.forceActiveFocus();
                }
                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                    if(currentView === 0) mainPlaylist.list.forceActiveFocus()
                    else if(currentView === 1) tracksView.forceActiveFocus()
                }

                TracksView
                {
                    id: tracksView
                    Connections
                    {
                        target: tracksView
                        onRowClicked: Player.addTrack(tracksView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(tracksView.model.get(index))
                        onPlayAll: Player.playAll(bae.get(Q.GET.allTracks))
                        onAppendAll: Player.appendAll(bae.get(Q.GET.allTracks))

                    }

                }

                AlbumsView
                {
                    id: albumsView
                    Connections
                    {
                        target: albumsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                ArtistsView
                {
                    id: artistsView

                    Connections
                    {
                        target: artistsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                PlaylistsView
                {
                    id: playlistsView
                    Connections
                    {
                        target: playlistsView
                        onRowClicked: Player.addTrack(track)
                        onQuickPlayTrack: Player.quickPlay(track)
                        onPlayAll: Player.playAll(tracks)
                        onAppendAll: Player.appendAll(tracks)
                    }
                }


                SearchTable
                {
                    id: searchView
                    Connections
                    {
                        target: searchView
                        onRowClicked: Player.addTrack(searchView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(searchView.model.get(index))
                        onPlayAll: Player.playAll(searchView.searchRes)
                        onAppendAll: Player.appendAll(searchView.searchRes)
                        onHeaderClosed: clearSearch()
                        onArtworkDoubleClicked:
                        {
                            var query = Q.GET.albumTracks_.arg(searchView.model.get(index).album)
                            query = query.arg(searchView.model.get(index).artist)

                            Player.playAll(bae.get(query))

                        }
                    }
                }

            }
        }
    }
    /*animations*/

    pageStack.layers.popEnter: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }
    pageStack.layers.popExit: Transition {
        YAnimator {
            from: 0
            to: pageStack.layers.height
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushEnter: Transition {
        YAnimator {
            from: pageStack.layers.height
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushExit: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    pageStack.layers.replaceEnter: Transition {
        YAnimator {
            from: pageStack.layers.width
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.replaceExit: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }
}
