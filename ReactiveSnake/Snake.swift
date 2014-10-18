import Foundation

public enum SnakeEvent {
    case Move
    case ChangeDirection(Direction)
    case Grow(Int)
}

public struct SnakeState {
    var worldSize : WorldSize
    var snake:Array<Point> = []
    var dead:Bool
}

public class Snake: StateSubject {
    typealias E = SnakeEvent
    typealias S = SnakeState
    
    private let state = Subject<SnakeState?>(nil)
    
	private var worldSize : WorldSize
	private var length:Int = 0
	private var points:Array<Point> = []
	private var direction:Direction = .left
	private var directionLocked:Bool = false

	init(inSize:WorldSize, length inLength:Int) {
		self.worldSize = inSize
		self.length = inLength

		let x:Int = self.worldSize.width / 2
		let y:Int = self.worldSize.height / 2
		for i in 0...inLength {
			var p:Point = Point(x:x + i, y: y)
			self.points.append(p)
		}
        
        self.state.value = SnakeState(worldSize: self.worldSize, snake: self.points, dead: self.isHeadHitBody())
	}
    
    public func tell(e:SnakeEvent) {
        switch e {
        case .Move:
            self.move()
        case .ChangeDirection(let direction):
            self.changeDirection(direction)
        case .Grow(let size):
            self.increaseLength(size)
        default:
            ()
        }
    }
    
    public func stream() -> Stream<SnakeState?> {
        return self.state.unwrap
    }

	private func move() {
		self.points.removeLast()
		let head = self.direction.move(points[0], worldSize: self.worldSize)
        self.points.insert(head, atIndex: 0)
        
        self.state.value = SnakeState(worldSize: self.worldSize, snake: self.points, dead: self.isHeadHitBody())
	}

	private func changeDirection(newDirection:Direction) {
        if self.direction.canChangeTo(newDirection) {
			self.direction = newDirection
		}
	}

	private func increaseLength(inLength:Int) {
		let lastPoint:Point = self.points[self.points.count-1]
		let theOneBeforeLastPoint:Point = self.points[self.points.count-2]
		var x = lastPoint.x - theOneBeforeLastPoint.x
		var y = lastPoint.y - theOneBeforeLastPoint.y
		if lastPoint.x == 0 &&
			theOneBeforeLastPoint.x == self.worldSize.width - 1	{
			x = 1
		}
		if (lastPoint.x == self.worldSize.width - 1 && theOneBeforeLastPoint.x == 0) {
			x = -1
		}
		if (lastPoint.y == 0 && theOneBeforeLastPoint.y == worldSize.height - 1) {
			y = 1
		}
		if (lastPoint.y == worldSize.height - 1 && theOneBeforeLastPoint.y == 0) {
			y = -1
		}
		for i in 0..<inLength {
			let theX:Int = (lastPoint.x + x * (i + 1)) % worldSize.width
			let theY:Int = (lastPoint.y + y * (i + 1)) % worldSize.height
			self.points.append(Point(x:theX, y:theY))
		}
	}

	private func isHeadHitBody() -> Bool {
		var headPoint = self.points[0]
		for bodyPoint in self.points[1..<self.points.count] {
			if (bodyPoint.x == headPoint.x &&
				bodyPoint.y == headPoint.y) {
					return true
			}
		}
		return false
	}
}