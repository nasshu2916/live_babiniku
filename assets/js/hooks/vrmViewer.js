import * as THREE from "three"
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js"
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js"
import { VRM, VRMUtils } from "@pixiv/three-vrm"
import { rigFace, rigPose, rigLeftHand, rigRightHand } from "./vrm/rig"

const loader = new GLTFLoader()
const renderer = new THREE.WebGLRenderer({ alpha: true })
const camera = new THREE.PerspectiveCamera(
  15.0,
  window.innerWidth / window.innerHeight,
  0.1,
  50.0
)
const scene = new THREE.Scene()
const clock = new THREE.Clock()
// const gridHelper = new THREE.GridHelper(30, 30)
let currentVrm

const vrmViewer = {
  mounted() {
    renderer.setSize(window.innerWidth, window.innerHeight)
    renderer.setPixelRatio(window.devicePixelRatio)

    this.el.appendChild(renderer.domElement)

    // camera
    camera.position.set(0.0, 1.3, 3.0)
    // camera controls
    const controls = new OrbitControls(camera, renderer.domElement)
    this.init_camera_controls(controls)

    // light
    const light = new THREE.DirectionalLight(0xffffff)
    light.position.set(1.0, 1.0, 1.0).normalize()
    scene.add(light)

    // gltf and vrm
    this.load_vrm("/models/alicia_solid.vrm")

    // helpers
    // scene.add(gridHelper)

    const animate = () => {
      requestAnimationFrame(animate)
      if (currentVrm) {
        // Update model to render physics
        currentVrm.update(clock.getDelta())
      }

      renderer.render(scene, camera)
    }

    animate()

    window.addEventListener("resize", this.onResize)

    this.handleEvent("changeRotation", (results) => {
      this.animateVRM(results)
    })
  },

  animateVRM({ riggedFace, riggedPose, riggedLeftHand, riggedRightHand }) {
    if (!currentVrm) {
      return
    }
    rigFace(currentVrm, riggedFace)
    rigPose(currentVrm, riggedPose)
    rigLeftHand(currentVrm, riggedLeftHand, riggedPose)
    rigRightHand(currentVrm, riggedRightHand, riggedPose)
  },

  load_vrm(file_path) {
    loader.crossOrigin = "anonymous"
    loader.load(
      file_path,

      (gltf) => {
        VRMUtils.removeUnnecessaryJoints(gltf.scene)

        // generate a VRM instance from gltf
        VRM.from(gltf).then((vrm) => {
          // add the loaded vrm to the scene
          scene.add(vrm.scene)
          currentVrm = vrm
          currentVrm.scene.rotation.y = Math.PI

          // deal with vrm features
          console.log(vrm)
        })
      },

      // called while loading is progressing
      (_progress) => {},

      // called when loading has errors
      (error) => console.error(error)
    )
  },

  init_camera_controls(controls) {
    controls.screenSpacePanning = true
    controls.target.set(0.0, 1.35, 0.0)

    controls.minPolarAngle = ((10 / 90) * Math.PI) / 2
    controls.maxPolarAngle = ((105 / 90) * Math.PI) / 2
    controls.update()
  },

  onResize() {
    const width = window.innerWidth
    const height = window.innerHeight

    renderer.setPixelRatio(window.devicePixelRatio)
    renderer.setSize(width, height)

    camera.aspect = width / height
    camera.updateProjectionMatrix()
  },
}

export default vrmViewer
