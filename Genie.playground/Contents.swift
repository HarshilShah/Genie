import SpriteKit
import PlaygroundSupport

enum GenieAnimationEdge {
	case top, bottom, left, right
	
	var isHorizontal: Bool {
		switch self {
		case .top, .bottom: return true
		case .left, .right: return false
		}
	}
}

enum GenieAnimationDirection {
	case minimize, maximize
}

func genie(maximized: CGRect, minimized: CGRect, direction: GenieAnimationDirection, edge: GenieAnimationEdge) -> SKAction {
	let slideAnimationEndFraction = 0.5
	let translateAnimationStartFraction = 0.4
	
	let duration = 0.7
	let fps = 60.0
	let frameCount = duration * fps

	let rowCount = edge.isHorizontal ? 50 : 1
	let columnCount = edge.isHorizontal ? 1 : 50
	
	let positions: [[SIMD2<Float>]] = {
		switch edge {
		case .top:
			let leftBezierTopX = Double(maximized.minX)
			let rightBezierTopX = Double(maximized.maxX)
			
			let leftEdgeDistanceToMove = Double(minimized.minX - maximized.minX)
			let rightEdgeDistanceToMove = Double(minimized.maxX - maximized.maxX)
			let verticalDistanceToMove = Double(minimized.maxY - maximized.maxY)
			
			let bezierTopY = Double(maximized.maxY)
			let bezierBottomY = Double(minimized.maxY)
			let bezierHeight = bezierTopY - bezierBottomY
			
			return stride(from: 0, to: frameCount, by: 1).map { frame in
				let fraction = (frame / (frameCount - 1))
				let slideProgress = max(0, min(1, fraction/slideAnimationEndFraction))
				let translateProgress = max(0, min(1, (fraction - translateAnimationStartFraction)/(1 - translateAnimationStartFraction)))
				
				let translation = translateProgress * verticalDistanceToMove
				let topEdgeVerticalPosition = Double(maximized.maxY) + translation
				let bottomEdgeVerticalPosition = max(
					Double(maximized.minY) + translation,
					Double(minimized.minY)
				)
				
				let leftBezierBottomX = leftBezierTopX + (slideProgress * leftEdgeDistanceToMove)
				let rightBezierBottomX = rightBezierTopX + (slideProgress * rightEdgeDistanceToMove)
				
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
			
		case .bottom:
			let leftBezierBottomX = Double(maximized.minX)
			let rightBezierBottomX = Double(maximized.maxX)
			
			let leftEdgeDistanceToMove = Double(minimized.minX - maximized.minX)
			let rightEdgeDistanceToMove = Double(minimized.maxX - maximized.maxX)
			let verticalDistanceToMove = Double(minimized.minY - maximized.minY)
			
			let bezierTopY = Double(minimized.minY)
			let bezierBottomY = Double(maximized.minY)
			let bezierHeight = bezierTopY - bezierBottomY
			
			return stride(from: 0, to: frameCount, by: 1).map { frame in
				let fraction = (frame / (frameCount - 1))
				let slideProgress = max(0, min(1, fraction/slideAnimationEndFraction))
				let translateProgress = max(0, min(1, (fraction - translateAnimationStartFraction)/(1 - translateAnimationStartFraction)))
				
				let translation = translateProgress * verticalDistanceToMove
				let topEdgeVerticalPosition = min(
					Double(maximized.maxY) + translation,
					Double(minimized.maxY)
				)
				let bottomEdgeVerticalPosition = Double(maximized.minY) + translation
				
				let leftBezierTopX = leftBezierBottomX + (slideProgress * leftEdgeDistanceToMove)
				let rightBezierTopX = rightBezierBottomX + (slideProgress * rightEdgeDistanceToMove)
				
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
			
		case .left:
			let topBezierLeftY = Double(maximized.maxY)
			let bottomBezierLeftY = Double(maximized.minY)
			
			let topEdgeDistanceToMove = Double(minimized.maxY - maximized.maxY)
			let bottomEdgeDistanceToMove = Double(minimized.minY - maximized.minY)
			let horizontalDistanceToMove = Double(minimized.minX - maximized.minX)
			
			let bezierLeftX = Double(maximized.minX)
			let bezierRightX = Double(minimized.minX)
			let bezierWidth = bezierRightX - bezierLeftX
			
			return stride(from: 0, to: frameCount, by: 1).map { frame in
				let fraction = (frame / (frameCount - 1))
				let slideProgress = max(0, min(1, fraction/slideAnimationEndFraction))
				let translateProgress = max(0, min(1, (fraction - translateAnimationStartFraction)/(1 - translateAnimationStartFraction)))
				
				let translation = translateProgress * horizontalDistanceToMove
				let leftEdgeHorizontalPosition = Double(maximized.minX) + translation
				let rightEdgeVerticalPosition = min(
					Double(maximized.maxX) + translation,
					Double(minimized.maxX)
				)
				
				let topBezierRightY = topBezierLeftY + (slideProgress * topEdgeDistanceToMove)
				let bottomBezierRightY = bottomBezierLeftY + (slideProgress * bottomEdgeDistanceToMove)
				
				func topBezierPosition(forX x: Double) -> Double {
					switch x {
					case ..<bezierLeftX:
						return topBezierLeftY
					case bezierLeftX ..< bezierRightX:
						let progress = ((x - bezierLeftX) / bezierWidth).quadraticEaseInOut
						return (progress * (topBezierRightY - topBezierLeftY)) + topBezierLeftY
					default:
						return topBezierRightY
					}
				}
				
				func bottomBezierPosition(forX x: Double) -> Double {
					switch x {
					case ..<bezierLeftX:
						return bottomBezierLeftY
					case bezierLeftX ..< bezierRightX:
						let progress = ((x - bezierLeftX) / bezierWidth).quadraticEaseInOut
						return (progress * (bottomBezierRightY - bottomBezierLeftY)) + bottomBezierLeftY
					default:
						return bottomBezierRightY
					}
				}
				
				let topEdgePositions = (0 ... columnCount)
					.map { Double($0) / Double(columnCount) }
					.map { position -> SIMD2<Double> in
						let x = (leftEdgeHorizontalPosition * (1 - position)) + (rightEdgeVerticalPosition * position)
						let y = topBezierPosition(forX: x)
						return SIMD2(x, y)
					}
					.map(SIMD2<Float>.init)
				
				let bottomEdgePositions = (0 ... columnCount)
					.map { Double($0) / Double(columnCount) }
					.map { position -> SIMD2<Double> in
						let x = (leftEdgeHorizontalPosition * (1 - position)) + (rightEdgeVerticalPosition * position)
						let y = bottomBezierPosition(forX: x)
						return SIMD2(x, y)
					}
					.map(SIMD2<Float>.init)
				
				return bottomEdgePositions + topEdgePositions
			}
			
		case .right:
			let topBezierRightY = Double(maximized.maxY)
			let bottomBezierRightY = Double(maximized.minY)
			
			let topEdgeDistanceToMove = Double(minimized.maxY - maximized.maxY)
			let bottomEdgeDistanceToMove = Double(minimized.minY - maximized.minY)
			let horizontalDistanceToMove = Double(minimized.maxX - maximized.maxX)
			
			let bezierLeftX = Double(minimized.maxX)
			let bezierRightX = Double(maximized.maxX)
			let bezierWidth = bezierRightX - bezierLeftX
			
			return stride(from: 0, to: frameCount, by: 1).map { frame in
				let fraction = (frame / (frameCount - 1))
				let slideProgress = max(0, min(1, fraction/slideAnimationEndFraction))
				let translateProgress = max(0, min(1, (fraction - translateAnimationStartFraction)/(1 - translateAnimationStartFraction)))
				
				let translation = translateProgress * horizontalDistanceToMove
				let leftEdgeHorizontalPosition = max(
					Double(maximized.minX) + translation,
					Double(minimized.minX)
				)
				let rightEdgeVerticalPosition = Double(maximized.maxX) + translation
				
				let topBezierLeftY = topBezierRightY + (slideProgress * topEdgeDistanceToMove)
				let bottomBezierLeftY = bottomBezierRightY + (slideProgress * bottomEdgeDistanceToMove)
				
				func topBezierPosition(forX x: Double) -> Double {
					switch x {
					case ..<bezierLeftX:
						return topBezierLeftY
					case bezierLeftX ..< bezierRightX:
						let progress = ((x - bezierLeftX) / bezierWidth).quadraticEaseInOut
						return (progress * (topBezierRightY - topBezierLeftY)) + topBezierLeftY
					default:
						return topBezierRightY
					}
				}
				
				func bottomBezierPosition(forX x: Double) -> Double {
					switch x {
					case ..<bezierLeftX:
						return bottomBezierLeftY
					case bezierLeftX ..< bezierRightX:
						let progress = ((x - bezierLeftX) / bezierWidth).quadraticEaseInOut
						return (progress * (bottomBezierRightY - bottomBezierLeftY)) + bottomBezierLeftY
					default:
						return bottomBezierRightY
					}
				}
				
				let topEdgePositions = (0 ... columnCount)
					.map { Double($0) / Double(columnCount) }
					.map { position -> SIMD2<Double> in
						let x = (leftEdgeHorizontalPosition * (1 - position)) + (rightEdgeVerticalPosition * position)
						let y = topBezierPosition(forX: x)
						return SIMD2(x, y)
					}
					.map(SIMD2<Float>.init)
				
				let bottomEdgePositions = (0 ... columnCount)
					.map { Double($0) / Double(columnCount) }
					.map { position -> SIMD2<Double> in
						let x = (leftEdgeHorizontalPosition * (1 - position)) + (rightEdgeVerticalPosition * position)
						let y = bottomBezierPosition(forX: x)
						return SIMD2(x, y)
					}
					.map(SIMD2<Float>.init)
				
				return bottomEdgePositions + topEdgePositions
			}
		}
	}()
	
	let orientedPositions = direction == .minimize ? positions : positions.reversed()
	
	let warps = orientedPositions.map {
		SKWarpGeometryGrid(columns: columnCount, rows: rowCount, destinationPositions: $0)
	}
	
	return SKAction.animate(
		withWarps: warps,
		times: warps.enumerated().map {
			NSNumber(value: Double($0.offset) / fps)
		}
	)!
}

let frame = CGRect(x: 0, y: 0, width: 800, height: 600)
let skView = SKView(frame: frame)
skView.appearance = NSAppearance(named: .aqua)
PlaygroundPage.current.liveView = skView

let scene = SKScene(size: frame.size)
scene.backgroundColor = .windowBackgroundColor

let imageNodes = [
	SKSpriteNode(imageNamed: "SysPrefs.png"),
	SKSpriteNode(imageNamed: "SysPrefs.png"),
	SKSpriteNode(imageNamed: "SysPrefs.png"),
	SKSpriteNode(imageNamed: "SysPrefs.png")
]

imageNodes.forEach { imageNode in
	imageNode.position = CGPoint(x: frame.midX, y: frame.midY)
	imageNode.size = frame.size
	scene.addChild(imageNode)
}

skView.presentScene(scene)

let initialFrame = CGRect(x: 200, y: 100, width: 400, height: 400)
	.normalized(in: skView.frame)
let initialPositions = [
	SIMD2(Float(initialFrame.minX), Float(initialFrame.minY)),
	SIMD2(Float(initialFrame.maxX), Float(initialFrame.minY)),
	SIMD2(Float(initialFrame.minX), Float(initialFrame.maxY)),
	SIMD2(Float(initialFrame.maxX), Float(initialFrame.maxY))
]
imageNodes.forEach { imageNode in
	imageNode.warpGeometry = SKWarpGeometryGrid(
		columns: 1,
		rows: 1,
		destinationPositions: initialPositions
	)
}

let endStates: [(edge: GenieAnimationEdge, origin: CGPoint)] = [
	(.top, CGPoint(x: 640, y: 0)),
	(.bottom, CGPoint(x: 120, y: 560)),
	(.right, CGPoint(x: 0, y: 80)),
	(.left, CGPoint(x: 760, y: 480)),
]

zip(imageNodes, endStates).forEach { imageNode, endState in
	let finalFrame = CGRect(origin: endState.origin, size: CGSize(width: 40, height: 40))
		.normalized(in: skView.frame)
	let action = genie(
		maximized: initialFrame,
		minimized: finalFrame,
		direction: .minimize,
		edge: endState.edge
	)
	imageNode.run(
		action
	)
}
