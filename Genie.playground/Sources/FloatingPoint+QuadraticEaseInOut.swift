public extension FloatingPoint {
	var quadraticEaseInOut: Self {
		if self < 1 / 2 {
			return 2 * self * self
		} else {
			return (-2 * self * self) + (4 * self) - 1
		}
	}
}
