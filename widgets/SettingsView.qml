import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../view_models"
import "../view_models/FolderPicker"

Drawer
{
    id: settingsView
    y: header.height
    height: parent.height - header.height - footer.height
    width: root.pageStack.wideMode ? views.width -1: root.width
    edge: Qt.RightEdge
    interactive: true
    focus: true
    modal:true
    dragMargin :0
    signal iconSizeChanged(int size)



    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
    }

    background: Rectangle
    {
        anchors.fill: parent
        color: bae.backgroundColor()
        z: -999
    }

    FolderDialog
    {
        id: folderDialog

        folder: bae.homeDir()
        onAccepted:
        {
            var path = folder.toString().replace("file://","")

            listModel.append({url: path})
            scanDir(path)
        }
    }
    FolderPicker
    {
        id: folderPicker

        Connections
        {
            target: folderPicker
            onPathClicked: folderPicker.load(path)

            onAccepted:
            {
                listModel.append({url: path})
                scanDir(path)
            }
            onGoBack: folderPicker.load(path)

        }
    }

    Rectangle
    {
        id: content
        anchors.fill: parent
        color: bae.midLightColor()
        ColumnLayout
        {
            width: settingsView.width
            height: settingsView.height


            ListView
            {
                id: sources
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Rectangle
                {
                    anchors.fill: parent
                    z: -999
                    color: bae.altColor()
                }

                ListModel
                {
                    id: listModel
                }

                model: listModel

                delegate: ItemDelegate
                {
                    width: parent.width

                    contentItem: ColumnLayout
                    {
                        spacing: 2
                        width: parent.width

                        Label
                        {
                            id: sourceUrl
                            width: parent.width
                            text: url
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            font.pointSize: 10
                            color: bae.foregroundColor()
                        }
                    }
                }

                Component.onCompleted:
                {
                    var map = bae.get("select url from folders order by addDate desc")
                    for(var i in map)
                        model.append(map[i])

                }
            }

            Row
            {
                id: sourceActions
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                height: 48

                BabeButton
                {
                    id: addSource

                    iconName: "list-add"

                    onClicked:
                    {

                        if(bae.isMobile())
                        {
                            folderPicker.open()
                            folderPicker.load(bae.homeDir())
                        }else
                            folderDialog.open()

                    }
                }

                BabeButton
                {
                    id: removeSource
                    iconName: "list-remove"
                    onClicked:
                    {

                    }

                }
            }

            Row
            {
                Layout.fillWidth: true
                height: 48
                Label
                {
                    padding: 20
                    text: "Toolbar icon size"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter

                    color: bae.foregroundColor()
                }

                ComboBox
                {
                    id: iconSize

                    model: ListModel
                    {
                        id: sizes
                        ListElement { size: 16 }
                        ListElement { size: 24 }
                        ListElement { size: 32 }
                    }

                    currentIndex:  1
                    onCurrentIndexChanged: iconSizeChanged(sizes.get(currentIndex).size )
                }
            }

            Row
            {
                Layout.fillWidth: true
                height: 48
                Label
                {
                    padding: 20
                    text: "Brainz"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter

                    color: bae.foregroundColor()
                }

                CheckBox
                {
                    id: brainzCheck
                    checkState: bae.loadSetting("BRAINZ", "BABE", false) === "true" ? Qt.Checked : Qt.Unchecked
                    onCheckStateChanged:
                    {
                        bae.saveSetting("BRAINZ",brainzCheck.checkState === Qt.Checked ? true : false, "BABE")

                        bae.brainz(brainzCheck.checkState === Qt.Checked ? true : false)

                    }
                }
            }
        }


    }
}
