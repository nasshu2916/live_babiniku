import { Camera } from "@mediapipe/camera_utils"
import {
  Holistic,
  HAND_CONNECTIONS,
  POSE_CONNECTIONS,
  FACEMESH_TESSELATION,
} from "@mediapipe/holistic"
import { drawConnectors, drawLandmarks } from "@mediapipe/drawing_utils"
import { Face, Pose, Hand } from "kalidokit"

let videoElement, guideCanvas, canvasCtx

const tracking = {
  mounted() {
    videoElement = this.el.querySelector("video")
    guideCanvas = this.el.querySelector("canvas")
    const holistic = new Holistic({
      locateFile: (file) => {
        return `https://cdn.jsdelivr.net/npm/@mediapipe/holistic@0.5.1635989137/${file}`
      },
    })
    holistic.setOptions({
      modelComplexity: 1,
      smoothLandmarks: true,
      minDetectionConfidence: 0.7,
      minTrackingConfidence: 0.7,
      refineFaceLandmarks: true,
    })

    holistic.onResults((results) => {
      guideCanvas.width = videoElement.videoWidth
      guideCanvas.height = videoElement.videoHeight

      canvasCtx = guideCanvas.getContext("2d")
      canvasCtx.save()
      canvasCtx.clearRect(0, 0, guideCanvas.width, guideCanvas.height)

      let riggedFace, riggedPose, riggedLeftHand, riggedRightHand

      const faceLandmarks = results.faceLandmarks
      // Pose 3D Landmarks are with respect to Hip distance in meters
      const pose3DLandmarks = results.ea
      // Pose 2D landmarks are with respect to videoWidth and videoHeight
      const pose2DLandmarks = results.poseLandmarks
      // Be careful, hand landmarks may be reversed
      const leftHandLandmarks = results.rightHandLandmarks
      const rightHandLandmarks = results.leftHandLandmarks

      if (faceLandmarks) {
        riggedFace = Face.solve(faceLandmarks, {
          runtime: "mediapipe",
          video: this.inputVideo,
        })
      }
      // Animate Pose
      if (pose2DLandmarks && pose3DLandmarks) {
        riggedPose = Pose.solve(pose3DLandmarks, pose2DLandmarks, {
          runtime: "mediapipe",
          video: this.inputVideo,
        })
      }
      // Animate Hands
      if (leftHandLandmarks) {
        riggedLeftHand = Hand.solve(leftHandLandmarks, "Left")
      }
      if (rightHandLandmarks) {
        riggedRightHand = Hand.solve(rightHandLandmarks, "Right")
      }
      // Use `Mediapipe` drawing functions
      drawResults(results)

      const solvedResult = {
        riggedFace,
        riggedPose,
        riggedLeftHand,
        riggedRightHand,
      }
      this.pushEvent("change", solvedResult)
    })
    const drawResults = (results) => {
      drawConnectors(canvasCtx, results.poseLandmarks, POSE_CONNECTIONS, {
        color: "#00cff7",
        lineWidth: 4,
      })
      drawLandmarks(canvasCtx, results.poseLandmarks, {
        color: "#ff0364",
        lineWidth: 2,
      })
      drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_TESSELATION, {
        color: "#C0C0C070",
        lineWidth: 1,
      })
      if (results.faceLandmarks && results.faceLandmarks.length === 478) {
        //draw pupils
        drawLandmarks(
          canvasCtx,
          [results.faceLandmarks[468], results.faceLandmarks[468 + 5]],
          {
            color: "#ffe603",
            lineWidth: 2,
          }
        )
      }
      drawConnectors(canvasCtx, results.leftHandLandmarks, HAND_CONNECTIONS, {
        color: "#eb1064",
        lineWidth: 5,
      })
      drawLandmarks(canvasCtx, results.leftHandLandmarks, {
        color: "#00cff7",
        lineWidth: 2,
      })
      drawConnectors(canvasCtx, results.rightHandLandmarks, HAND_CONNECTIONS, {
        color: "#22c3e3",
        lineWidth: 5,
      })
      drawLandmarks(canvasCtx, results.rightHandLandmarks, {
        color: "#ff0364",
        lineWidth: 2,
      })
    }
    const camera = new Camera(videoElement, {
      onFrame: async () => {
        await holistic.send({ image: videoElement })
      },
      width: 1280,
      height: 720,
    })

    this.el.addEventListener("start_tracking", () => {
      camera.start()
    })

    this.el.addEventListener("stop_tracking", () => {
      camera.stop()
    })
  },
}

export default tracking
