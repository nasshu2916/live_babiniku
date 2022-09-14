import * as THREE from "three"
import { VRMSchema } from "@pixiv/three-vrm"

export function rigRotation(
  currentVrm,
  boneName,
  rotation = { x: 0, y: 0, z: 0 },
  dampener = 1,
  lerpAmount = 0.3
) {
  if (!currentVrm) {
    return
  }
  const Part = currentVrm.humanoid.getBoneNode(
    VRMSchema.HumanoidBoneName[boneName]
  )
  if (!Part) {
    return
  }

  let euler = new THREE.Euler(
    rotation.x * dampener,
    rotation.y * dampener,
    rotation.z * dampener,
    rotation.rotationOrder || "XYZ"
  )
  let quaternion = new THREE.Quaternion().setFromEuler(euler)
  Part.quaternion.slerp(quaternion, lerpAmount) // interpolate
}

export function rigPosition(
  currentVrm,
  boneName,
  position = { x: 0, y: 0, z: 0 },
  dampener = 1,
  lerpAmount = 0.3
) {
  if (!currentVrm) {
    return
  }
  const Part = currentVrm.humanoid.getBoneNode(
    VRMSchema.HumanoidBoneName[boneName]
  )
  if (!Part) {
    return
  }
  let vector = new THREE.Vector3(
    position.x * dampener,
    position.y * dampener,
    position.z * dampener
  )
  Part.position.lerp(vector, lerpAmount) // interpolate
}
