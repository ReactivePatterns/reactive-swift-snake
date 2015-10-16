import UIKit

class GameView : UIView {

    var worldSize:WorldSize?
    var points:[Point]?
    var apple:Point?

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = UIColor.whiteColor()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.whiteColor()
	}

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
			if worldSize?.width <= 0 || worldSize?.height <= 0 {
				return
			}
			let w = Int(Float(self.bounds.size.width) / Float(worldSize!.width))
			let h = Int(Float(self.bounds.size.height) / Float(worldSize!.height))

			UIColor.blackColor().set()
			for point in points! {
                UIColor.greenColor().set()
				let rect = CGRect(x: point.x * w, y: point.y * h, width: w, height: h)
				UIBezierPath(rect: rect).fill()
			}

			if let fruit = self.apple {
				UIColor.redColor().set()
				let rect = CGRect(x: fruit.x * w, y: fruit.y * h, width: w, height: h)
				UIBezierPath(ovalInRect: rect).fill()
			}
	}
    
    func update(gameState: GameState) {
        self.worldSize = gameState.worldSize
        self.points = gameState.snake
        self.apple = gameState.apple
        super.setNeedsDisplay()
    }
}
