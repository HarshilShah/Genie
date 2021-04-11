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
