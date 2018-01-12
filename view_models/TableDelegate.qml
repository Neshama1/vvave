import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../utils/Icons.js" as MdiFont
import "../utils"

ItemDelegate
{
    id: delegate
    signal playTrack()
    signal queueTrack()
    signal menuClicked()

    property string textColor: util.foregroundColor()
    property bool number : false
    property bool quickBtns : false
    checkable: true

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked:
        {
            if(Qt.platform.os === "linux")
                if (mouse.button == Qt.RightButton)
                    menuClicked()
        }
    }

    contentItem: GridLayout
    {
        id: gridLayout
        width: parent.width

        rows:2
        columns:3

        Label
        {
            id: trackNumber
            visible: number
            width: 16
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 1
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignCenter

            text: track
            font.bold: true
            elide: Text.ElideRight

            font.pointSize: 10
            color: textColor
        }


        Label
        {
            id: trackTitle

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 2

            text: title
            font.bold: true
            elide: Text.ElideRight

            font.pointSize: 10
            color: textColor

        }

        Label
        {
            id: trackInfo

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 2
            Layout.column: 2

            text: artist + " | " + album
            font.bold: false
            elide: Text.ElideRight
            font.pointSize: 9
            color: textColor

        }

        Row
        {
            Layout.column: 3
            Layout.row: 1
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignRight
            visible: quickBtns || menuBtn.visible

            ToolButton
            {
                id: queueBtn
                visible: Qt.platform.os === "android"
                Icon { text: MdiFont.Icon.clock }
                onClicked: queueTrack()
            }

            ToolButton
            {

                id: playBtn
                Icon { text: MdiFont.Icon.playCircle }
                onClicked: playTrack()
            }

            ToolButton
            {
                id: menuBtn
                visible: Qt.platform.os === "android"
                Icon { text: MdiFont.Icon.dotsVertical }
                onClicked: menuClicked()
            }
        }


    }
}
