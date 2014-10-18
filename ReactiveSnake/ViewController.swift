import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var startButton:UIButton?
    var game: Game?
	var gameView:GameView?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.gameView = GameView(frame: self.view.bounds)
		self.gameView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
		self.view.insertSubview(self.gameView!, atIndex: 0)

		for direction in [UISwipeGestureRecognizerDirection.Right,
			UISwipeGestureRecognizerDirection.Left,
			UISwipeGestureRecognizerDirection.Up,
			UISwipeGestureRecognizerDirection.Down] {
				let gr = UISwipeGestureRecognizer(target: self, action: "swipe:")
				gr.direction = direction
				self.view.addGestureRecognizer(gr)
		}
	}

	func swipe (gr:UISwipeGestureRecognizer) {
		let direction = gr.direction
		switch direction {
		case UISwipeGestureRecognizerDirection.Right:
            self.game?.tell(GameEvent.ChangeDirection(Direction.right))
		case UISwipeGestureRecognizerDirection.Left:
            self.game?.tell(GameEvent.ChangeDirection(Direction.left))
		case UISwipeGestureRecognizerDirection.Up:
            self.game?.tell(GameEvent.ChangeDirection(Direction.up))
		case UISwipeGestureRecognizerDirection.Down:
            self.game?.tell(GameEvent.ChangeDirection(Direction.down))
		default:
			assert(false, "This could not happen")
		}
	}
    
    func startGame() {
        self.startButton!.hidden = true
        self.game = Game()
        self.game?.tell(GameEvent.Start)
        self.game?.stream().subscribe { (e: Packet<GameState?>) in
            if let gameState = e.value {
                if (gameState == nil) {
                    return
                }
                self.gameView?.update(gameState!)
                if (gameState!.end) {
                    self.endGame()
                }
            }
        }
	}

	func endGame() {
		self.startButton!.hidden = false
        self.game?.tell(GameEvent.End)
    }

	@IBAction func start(sender:AnyObject) {
		self.startGame()
	}
}
