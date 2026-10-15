import QtQuick
import qs.Commons

// The island's status light: a thin line of light along its lower lip.
// Its color, brightness and shape say what the island is doing:
//   glow      - a soft centered line (idle, playing, recording)
//   progress  - fills from the left (timer, volume, a script's progress)
// Vector rectangles and gradients only, so it stays crisp.
Item {
  id: edge

  property color tone: "white"
  property real level: 0.3          // 0..1 brightness
  property real progress: -1        // 0..1, or -1 for a glow
  property bool pulse: false        // breathe (recording, playing)
  property real pulsePeriod: 1400

  height: 2

  property real breath: 1
  readonly property real shown: level * (pulse ? breath : 1)

  SequentialAnimation on breath {
    running: edge.pulse && edge.visible
    loops: Animation.Infinite
    NumberAnimation { to: 0.45; duration: edge.pulsePeriod / 2; easing.type: Easing.InOutSine }
    NumberAnimation { to: 1; duration: edge.pulsePeriod / 2; easing.type: Easing.InOutSine }
    onRunningChanged: if (!running) edge.breath = 1
  }

  Behavior on level { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
  Behavior on tone { ColorAnimation { duration: 450 } }

  // Glow: bright in the middle, gone at the ends.
  Rectangle {
    anchors.fill: parent
    radius: height / 2
    visible: edge.progress < 0
    opacity: edge.shown
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: Util.alpha(edge.tone, 0) }
      GradientStop { position: 0.3; color: Util.alpha(edge.tone, 0.85) }
      GradientStop { position: 0.5; color: edge.tone }
      GradientStop { position: 0.7; color: Util.alpha(edge.tone, 0.85) }
      GradientStop { position: 1.0; color: Util.alpha(edge.tone, 0) }
    }
  }

  // Progress: a faint track and a fill with a bright head.
  Item {
    anchors.fill: parent
    visible: edge.progress >= 0

    Rectangle {
      anchors.fill: parent
      radius: height / 2
      color: Util.alpha(edge.tone, 0.14 * edge.level)
    }

    Rectangle {
      height: parent.height
      radius: height / 2
      width: parent.width * Math.max(0, Math.min(1, edge.progress))
      opacity: edge.shown
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: Util.alpha(edge.tone, 0.35) }
        GradientStop { position: 1.0; color: edge.tone }
      }

      Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    }
  }
}
