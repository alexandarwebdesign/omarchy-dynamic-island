import QtQuick
import qs.Commons

// Shortcuts to every island view, so any of them can be reached with the
// mouse. The current one is lit; the ones that need something live (timer,
// activity, recording, a player) are dimmed until there is something to show.
Item {
  id: sw

  property var island: null

  readonly property var live: island ? island.activityList : []
  readonly property bool hasTimer: live.indexOf("timer") !== -1 || live.indexOf("stopwatch") !== -1
  readonly property bool hasActivity: live.indexOf("activity") !== -1
  readonly property bool hasRecording: live.indexOf("recording") !== -1

  readonly property string current: {
    var v = island ? island.view : ""
    if (v === "media-expanded") return "media"
    if (v === "idle-expanded") return "panel"
    if (v === "outputs-expanded") return "outputs"
    if (v === "clock-expanded") return "timer"
    if (v === "activity-expanded") return "activity"
    if (v.indexOf("recording") === 0) return "recording"
    if (v === "calendar-expanded") return "calendar"
    if (v === "inbox-expanded") return "inbox"
    return ""
  }

  readonly property var items: [
    { key: "media",     glyph: "󰝚", ready: island ? island.hasMedia : false },
    { key: "panel",     glyph: "󰔛", ready: true },
    { key: "outputs",   glyph: "󰋋", ready: true },
    { key: "timer",     glyph: "󱎫", ready: hasTimer },
    { key: "activity",  glyph: "󰏗", ready: hasActivity },
    { key: "recording", glyph: "",   ready: hasRecording },
    { key: "calendar",  glyph: "󰃭", ready: true },
    { key: "inbox",     glyph: "󰂚", ready: true }
  ]

  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: island ? island.s(7) : 7
    spacing: island ? island.s(4) : 4

    Repeater {
      model: sw.items

      Rectangle {
        id: button
        required property var modelData
        readonly property bool lit: sw.current === modelData.key
        width: sw.island.s(30)
        height: sw.island.s(26)
        radius: height / 2
        opacity: modelData.ready ? 1 : 0.35
        color: lit ? Util.alpha(sw.island.accentColor, 0.28)
                   : Util.alpha(sw.island.fg, mouse.pressed ? 0.2 : (mouse.containsMouse && modelData.ready ? 0.12 : 0.05))

        Behavior on color { ColorAnimation { duration: 120 } }

        // A drawn dot for recording, a glyph for the rest.
        Rectangle {
          visible: modelData.key === "recording"
          anchors.centerIn: parent
          width: sw.island.s(9)
          height: width
          radius: width / 2
          color: lit || modelData.ready ? sw.island.urgentColor : sw.island.fg
        }

        Text {
          visible: modelData.key !== "recording"
          anchors.centerIn: parent
          text: modelData.glyph
          textFormat: Text.PlainText
          renderType: Text.NativeRendering
          font.family: sw.island.fontFamily
          font.pixelSize: sw.island.f(14)
          color: lit ? sw.island.accentColor : sw.island.fg
        }

        // How many missed notifications wait in the inbox.
        Rectangle {
          visible: modelData.key === "inbox" && sw.island.inbox.length > 0
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.rightMargin: -sw.island.s(2)
          anchors.topMargin: -sw.island.s(2)
          width: Math.max(height, countText.implicitWidth + sw.island.s(6))
          height: sw.island.s(13)
          radius: height / 2
          color: sw.island.accentColor

          Text {
            id: countText
            anchors.centerIn: parent
            text: sw.island.inbox.length > 9 ? "9+" : String(sw.island.inbox.length)
            textFormat: Text.PlainText
            font.family: sw.island.textFamily
            font.pixelSize: sw.island.f(9)
            font.weight: Font.DemiBold
            color: sw.island.surfaceBottom
          }
        }

        MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          enabled: modelData.ready
          cursorShape: modelData.ready ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: sw.island.setView(modelData.key)
        }
      }
    }
  }
}
