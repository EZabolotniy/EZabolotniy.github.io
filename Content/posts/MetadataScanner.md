---
date: 2022-10-10 16:31
description: In this post we try to create QR and barcodes scanner.
tags: AVFoundation, Vision
---
# QR scanner

Naive approche – use AVFoundation only

```
class ObjectDetectionMetadataRecognitionController {

  private let previewLayer: CALayer
  private let previewTransform: (RelativePoint) -> CGPoint

  init(
    previewLayer: CALayer,
    previewTransform: @escaping (RelativePoint) -> CGPoint
  ) {
    self.previewLayer = previewLayer
    self.previewTransform = previewTransform
  }

  private func onCodeObjectsReceived(_ codeObjects: [MachineReadableCodeObject]) {
    let codeObjects = codeObjects.map {
      MachineReadableCodeObject(
        stringValue: $0.stringValue,
        corners: $0.corners.map { corner in
          previewTransform(RelativePoint(rawValue: corner))
        },
        time: $0.time,
        type: $0.type
      )
    }
    removeCodeObjectFromSuperview()
    presentCodeObjects(codeObjects)
  }

  private func removeCodeObjectFromSuperview() {
    previewLayer.sublayers?.forEach {
      $0.removeFromSuperlayer()
    }
  }

  private func presentCodeObjects(_ codeObjects: [MachineReadableCodeObject]) {
    codeObjects.forEach {
      previewLayer.addSublayer($0.layer)
    }
  }
}

extension ObjectDetectionMetadataRecognitionController: PreviewMetadataDelegate {
  func didCaptureCodeObjects(_ codeObjects: [MachineReadableCodeObject]) {
    onMainThread { self.onCodeObjectsReceived(codeObjects) }
  }
}

extension MachineReadableCodeObject {
  fileprivate var layer: CALayer {
//    let shapeLayer = CAShapeLayer()
//    shapeLayer.strokeColor = Color.white.cgColor
//    shapeLayer.fillColor = Color.clear.cgColor
//    shapeLayer.lineWidth = 2
//    shapeLayer.lineJoin = .round
//    shapeLayer.path = corners.path

    let shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = Color.white.cgColor
    shapeLayer.path = corners.dotPath

    return shapeLayer
  }
}

extension Collection where Element == CGPoint {
  fileprivate var rectPath: CGPath {
    let path = CGMutablePath()
    first.apply {
      path.move(to: $0)
    }
    dropFirst().forEach {
      path.addLine(to: $0)
    }
    path.closeSubpath()
    return path
  }

  fileprivate var dotPath: CGPath {
    let minX = self.min (by: { $0.x < $1.x })!.x
    let minY = self.min (by: { $0.y < $1.y })!.y
    let maxX = self.max (by: { $0.x < $1.x })!.x
    let maxY = self.max (by: { $0.y < $1.y })!.y
    let origin = CGPoint(
      x: minX + (maxX - minX)/2,
      y: minY + (maxY - minY)/2
    )
    return UIBezierPath(
      ovalIn: CGRect(origin: origin, size: CGSize(width: 10, height: 10))
    ).cgPath
  }
}
```

Result: (TODO: upload video)
