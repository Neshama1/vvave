import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView
{
    id: babeList

    property alias holder : holder
    signal pulled()

    property bool wasPulled : false


    clip: true

    highlight: Rectangle
    {
        width: babeList.width
        height: babeList.currentItem.height
        color: babeHighlightColor
//        y: babeList.currentItem.y
//        Behavior on y
//        {
//            SpringAnimation
//            {
//                spring: 3
//                damping: 0.2
//            }
//        }
    }

    focus: true
    interactive: true
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    keyNavigationWraps: !isMobile
    keyNavigationEnabled : !isMobile

    Keys.onUpPressed: decrementCurrentIndex()
    Keys.onDownPressed: incrementCurrentIndex()
    Keys.onReturnPressed: rowClicked(currentIndex)
    Keys.onEnterPressed: quickPlayTrack(currentIndex)

    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    flickableDirection: Flickable.AutoFlickDirection

    snapMode: ListView.SnapToItem

    addDisplaced: Transition
    {
        NumberAnimation { properties: "x,y"; duration: 1000 }
    }

    function clearTable()
    {
        listModel.clear()
    }

    BabeHolder
    {
        id: holder
        visible: count === 0
    }

    Rectangle
    {
        anchors.fill: parent
        color: "transparent"
        z: -999
    }


    ScrollBar.vertical:BabeScrollBar { }


    onContentYChanged:
    {
        if(contentY < -120)
            wasPulled = true

        if(contentY == toolBarHeight*-1 && wasPulled)
        { pulled(); wasPulled = false}
    }

}
