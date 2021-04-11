import CoreGraphics

public extension CGRect {
	func normalized(in other: CGRect) -> CGRect {
		CGRect(
			x: (origin.x - other.origin.x) / other.width,
			y: (origin.y - other.origin.y) / other.height,
			width: width / other.width,
			height: height / other.height
		)
	}
}
