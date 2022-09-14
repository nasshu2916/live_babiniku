import * as THREE from "three"
import { VRMSchema } from "@pixiv/three-vrm"
import { Face, Utils, Vector } from "kalidokit"
import { rigRotation } from "./rigHelper"

let oldLookTarget = new THREE.Euler()

// const remap = Utils.remap;
const clamp = Utils.clamp
const lerp = Vector.lerp

export function rigFace(currentVrm, riggedFace) {
  if (!currentVrm || !riggedFace) {
    return
  }

  rigRotation(currentVrm, "Neck", riggedFace.head, 0.7)

  // Blendshapes and Preset Name Schema
  const Blendshape = currentVrm.blendShapeProxy
  const PresetName = VRMSchema.BlendShapePresetName

  // Simple example without winking. Interpolate based on old blendshape, then stabilize blink with `Kalidokit` helper function.
  // for VRM, 1 is closed, 0 is open.
  riggedFace.eye.l = lerp(
    clamp(1 - riggedFace.eye.l, 0, 1),
    Blendshape.getValue(PresetName.Blink),
    0.5
  )
  riggedFace.eye.r = lerp(
    clamp(1 - riggedFace.eye.r, 0, 1),
    Blendshape.getValue(PresetName.Blink),
    0.5
  )
  riggedFace.eye = Face.stabilizeBlink(riggedFace.eye, riggedFace.head.y)
  Blendshape.setValue(PresetName.Blink, riggedFace.eye.l)

  // Interpolate and set mouth blendshapes
  Blendshape.setValue(
    PresetName.I,
    lerp(riggedFace.mouth.shape.I, Blendshape.getValue(PresetName.I), 0.5)
  )
  Blendshape.setValue(
    PresetName.A,
    lerp(riggedFace.mouth.shape.A, Blendshape.getValue(PresetName.A), 0.5)
  )
  Blendshape.setValue(
    PresetName.E,
    lerp(riggedFace.mouth.shape.E, Blendshape.getValue(PresetName.E), 0.5)
  )
  Blendshape.setValue(
    PresetName.O,
    lerp(riggedFace.mouth.shape.O, Blendshape.getValue(PresetName.O), 0.5)
  )
  Blendshape.setValue(
    PresetName.U,
    lerp(riggedFace.mouth.shape.U, Blendshape.getValue(PresetName.U), 0.5)
  )

  //PUPILS
  //interpolate pupil and keep a copy of the value
  let lookTarget = new THREE.Euler(
    lerp(oldLookTarget.x, riggedFace.pupil.y, 0.4),
    lerp(oldLookTarget.y, riggedFace.pupil.x, 0.4),
    0,
    "XYZ"
  )
  oldLookTarget.copy(lookTarget)
  currentVrm.lookAt.applyer.lookAt(lookTarget)
}

export function rigPose(currentVrm, riggedPose) {
  if (!currentVrm || !riggedPose) {
    return
  }

  rigRotation(currentVrm, "Chest", riggedPose.Spine, 0.25, 0.3)
  rigRotation(currentVrm, "Spine", riggedPose.Spine, 0.45, 0.3)

  rigRotation(currentVrm, "RightUpperArm", riggedPose.RightUpperArm, 1, 0.3)
  rigRotation(currentVrm, "RightLowerArm", riggedPose.RightLowerArm, 1, 0.3)
  rigRotation(currentVrm, "LeftUpperArm", riggedPose.LeftUpperArm, 1, 0.3)
  rigRotation(currentVrm, "LeftLowerArm", riggedPose.LeftLowerArm, 1, 0.3)

  // rigRotation(currentVrm, "Hips", riggedPose.Hips.rotation, 0.7)
  // rigPosition(
  //   currentVrm,
  //   "Hips",
  //   {
  //     x: riggedPose.Hips.position.x, // Reverse direction
  //     y: riggedPose.Hips.position.y + 1, // Add a bit of height
  //     z: -riggedPose.Hips.position.z, // Reverse direction
  //   },
  //   1,
  //   0.07
  // )

  // rigRotation(currentVrm, "LeftUpperLeg", riggedPose.LeftUpperLeg, 1, 0.3)
  // rigRotation(currentVrm, "LeftLowerLeg", riggedPose.LeftLowerLeg, 1, 0.3)
  // rigRotation(currentVrm, "RightUpperLeg", riggedPose.RightUpperLeg, 1, 0.3)
  // rigRotation(currentVrm, "RightLowerLeg", riggedPose.RightLowerLeg, 1, 0.3)
}

export function rigLeftHand(currentVrm, riggedLeftHand, riggedPose) {
  if (!currentVrm || !riggedLeftHand) {
    return
  }

  rigRotation(currentVrm, "LeftHand", {
    // Combine pose rotation Z and hand rotation X Y
    z: riggedPose.LeftHand.z,
    y: riggedLeftHand.LeftWrist.y,
    x: riggedLeftHand.LeftWrist.x,
  })
  rigRotation(currentVrm, "LeftRingProximal", riggedLeftHand.LeftRingProximal)
  rigRotation(
    currentVrm,
    "LeftRingIntermediate",
    riggedLeftHand.LeftRingIntermediate
  )
  rigRotation(currentVrm, "LeftRingDistal", riggedLeftHand.LeftRingDistal)
  rigRotation(currentVrm, "LeftIndexProximal", riggedLeftHand.LeftIndexProximal)
  rigRotation(
    currentVrm,
    "LeftIndexIntermediate",
    riggedLeftHand.LeftIndexIntermediate
  )
  rigRotation(currentVrm, "LeftIndexDistal", riggedLeftHand.LeftIndexDistal)
  rigRotation(
    currentVrm,
    "LeftMiddleProximal",
    riggedLeftHand.LeftMiddleProximal
  )
  rigRotation(
    currentVrm,
    "LeftMiddleIntermediate",
    riggedLeftHand.LeftMiddleIntermediate
  )
  rigRotation(currentVrm, "LeftMiddleDistal", riggedLeftHand.LeftMiddleDistal)
  rigRotation(currentVrm, "LeftThumbProximal", riggedLeftHand.LeftThumbProximal)
  rigRotation(
    currentVrm,
    "LeftThumbIntermediate",
    riggedLeftHand.LeftThumbIntermediate
  )
  rigRotation(currentVrm, "LeftThumbDistal", riggedLeftHand.LeftThumbDistal)
  rigRotation(
    currentVrm,
    "LeftLittleProximal",
    riggedLeftHand.LeftLittleProximal
  )
  rigRotation(
    currentVrm,
    "LeftLittleIntermediate",
    riggedLeftHand.LeftLittleIntermediate
  )
  rigRotation(currentVrm, "LeftLittleDistal", riggedLeftHand.LeftLittleDistal)
}

export function rigRightHand(currentVrm, riggedRightHand, riggedPose) {
  if (!currentVrm || !riggedRightHand) {
    return
  }

  rigRotation(currentVrm, "RightHand", {
    // Combine Z axis from pose hand and X/Y axis from hand wrist rotation
    z: riggedPose.RightHand.z,
    y: riggedRightHand.RightWrist.y,
    x: riggedRightHand.RightWrist.x,
  })
  rigRotation(
    currentVrm,
    "RightRingProximal",
    riggedRightHand.RightRingProximal
  )
  rigRotation(
    currentVrm,
    "RightRingIntermediate",
    riggedRightHand.RightRingIntermediate
  )
  rigRotation(currentVrm, "RightRingDistal", riggedRightHand.RightRingDistal)
  rigRotation(
    currentVrm,
    "RightIndexProximal",
    riggedRightHand.RightIndexProximal
  )
  rigRotation(
    currentVrm,
    "RightIndexIntermediate",
    riggedRightHand.RightIndexIntermediate
  )
  rigRotation(currentVrm, "RightIndexDistal", riggedRightHand.RightIndexDistal)
  rigRotation(
    currentVrm,
    "RightMiddleProximal",
    riggedRightHand.RightMiddleProximal
  )
  rigRotation(
    currentVrm,
    "RightMiddleIntermediate",
    riggedRightHand.RightMiddleIntermediate
  )
  rigRotation(
    currentVrm,
    "RightMiddleDistal",
    riggedRightHand.RightMiddleDistal
  )
  rigRotation(
    currentVrm,
    "RightThumbProximal",
    riggedRightHand.RightThumbProximal
  )
  rigRotation(
    currentVrm,
    "RightThumbIntermediate",
    riggedRightHand.RightThumbIntermediate
  )
  rigRotation(currentVrm, "RightThumbDistal", riggedRightHand.RightThumbDistal)
  rigRotation(
    currentVrm,
    "RightLittleProximal",
    riggedRightHand.RightLittleProximal
  )
  rigRotation(
    currentVrm,
    "RightLittleIntermediate",
    riggedRightHand.RightLittleIntermediate
  )
  rigRotation(
    currentVrm,
    "RightLittleDistal",
    riggedRightHand.RightLittleDistal
  )
}
