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
