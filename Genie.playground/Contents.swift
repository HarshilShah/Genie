import SpriteKit
import PlaygroundSupport

let frame = CGRect(x: 0, y: 0, width: 800, height: 600)
let skView = SKView(frame: frame)
skView.appearance = NSAppearance(named: .aqua)
PlaygroundPage.current.liveView = skView

let scene = SKScene(size: frame.size)
scene.backgroundColor = .windowBackgroundColor

let imageNode = SKSpriteNode(imageNamed: "SysPrefs.png")
imageNode.position = CGPoint(x: frame.midX, y: frame.midY)
imageNode.size = frame.size
scene.addChild(imageNode)

skView.presentScene(scene)

let initialFrame = CGRect(x: 200, y: 100, width: 400, height: 400)
	.normalized(in: skView.frame)
let initialPositions = [
	SIMD2(Float(initialFrame.minX), Float(initialFrame.minY)),
	SIMD2(Float(initialFrame.maxX), Float(initialFrame.minY)),
	SIMD2(Float(initialFrame.minX), Float(initialFrame.maxY)),
	SIMD2(Float(initialFrame.maxX), Float(initialFrame.maxY))
]
imageNode.warpGeometry = SKWarpGeometryGrid(
	columns: 1,
	rows: 1,
	destinationPositions: initialPositions
)

let finalFrame = CGRect(x: 640, y: 0, width: 50, height: 50)
	.normalized(in: skView.frame)

let slideAnimationEndFraction = 0.5
let translateAnimationStartFraction = 0.4
let leftBezierTopX = Double(initialFrame.minX)
let rightBezierTopX = Double(initialFrame.maxX)

let duration = 0.7
let fps = 60.0
let frameCount = duration * fps

let rowCount = 50

let leftEdgeDistanceToMove = Double(finalFrame.minX - initialFrame.minX)
let rightEdgeDistanceToMove = Double(finalFrame.maxX - initialFrame.maxX)
let verticalDistanceToMove = Double(finalFrame.maxY - initialFrame.maxY)

let bezierTopY = Double(initialFrame.maxY)
let bezierBottomY = Double(finalFrame.maxY)
let bezierHeight = bezierTopY - bezierBottomY

let positions: [[SIMD2<Float>]] = stride(from: 0, to: frameCount, by: 1).map { frame in
	let fraction = (frame / (frameCount - 1))
	let slideProgress = max(0, min(1, fraction/slideAnimationEndFraction))
	let translateProgress = max(0, min(1, (fraction - translateAnimationStartFraction)/(1 - translateAnimationStartFraction)))
	
	let translation = translateProgress * verticalDistanceToMove
	let topEdgeVerticalPosition = Double(initialFrame.maxY) + translation
	let bottomEdgeVerticalPosition = max(
		Double(initialFrame.minY) + translation,
		Double(finalFrame.minY)
	)
	
	let leftBezierBottomX = leftBezierTopX + (slideProgress * leftEdgeDistanceToMove)
	let rightBezierBottomX = Double(initialFrame.maxX) + (slideProgress * rightEdgeDistanceToMove)
	
	func leftBezierPosition(forY y: Double) -> Double {
		switch y {
		case ..<bezierBottomY:
			return leftBezierBottomX
		case bezierBottomY ..< bezierTopY:
			let progress = ((y - bezierBottomY) / bezierHeight).quadraticEaseInOut
			return (progress * (leftBezierTopX - leftBezierBottomX)) + leftBezierBottomX
		default:
			return leftBezierTopX
		}
	}
	
	func rightBezierPosition(forY y: Double) -> Double {
		switch y {
		case ..<bezierBottomY:
			return rightBezierBottomX
		case bezierBottomY ..< bezierTopY:
			let progress = ((y - bezierBottomY) / bezierHeight).quadraticEaseInOut
			return (progress * (rightBezierTopX - rightBezierBottomX)) + rightBezierBottomX
		default:
			return rightBezierTopX
		}
	}
	
	return (0 ... rowCount)
		.map { Double($0) / Double(rowCount) }
		.flatMap { position -> [SIMD2<Double>] in
			let y = (topEdgeVerticalPosition * position) + (bottomEdgeVerticalPosition * (1 - position))
			let xMin = leftBezierPosition(forY: y)
			let xMax = rightBezierPosition(forY: y)
			return [SIMD2(xMin, y), SIMD2(xMax, y)]
		}
		.map(SIMD2<Float>.init)
}

let warps = positions.map {
	SKWarpGeometryGrid(columns: 1, rows: rowCount, destinationPositions: $0)
}
let warpAction = SKAction.animate(
	withWarps: warps,
	times: warps.enumerated().map {
		NSNumber(value: Double($0.offset) / fps)
	}
)!
imageNode.run(warpAction)
