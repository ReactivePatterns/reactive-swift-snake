import Foundation

public enum GameEvent {
    case Start
    case End
    case ChangeDirection(Direction)
}

public struct GameState {
    var worldSize : WorldSize
    var snake:Array<Point> = []
    var apple:Point
    var end:Bool
}

//public class GameSubject: NSObject, StateSubject {
//    typealias E = GameEvent
//    typealias S = GameState
//    
//    public func tell(event:GameEvent) {}
//    public func stream() -> Stream<GameState?> {return Streams.pure(nil)}}

public class Game: NSObject, StateSubject {
    
    private var snake:Snake?
    private var apple:Apple?
    private var fruit:Point?
    private var timer:NSTimer?
    private var worldSize:WorldSize?
    
    private let state = Subject<GameState?>(nil)
    
    override init() {
        super.init()
        self.worldSize = WorldSize(width: 24, height: 15)
    }
    
    public func tell(e:GameEvent) {
        switch e {
            case .Start:
                self.start()
            case .End:
                self.end()
            case .ChangeDirection(let direction):
                self.snake?.tell(.ChangeDirection(direction))
            default:
                ()
        }
    }
    
    public func stream() -> Stream<GameState?> {
        return self.state.unwrap
    }
    
    func tick() {
        self.snake?.tell(.Move)
    }
    
    private func start() {
        if (self.timer != nil) {
            return
        }

        self.snake = Snake(inSize: self.worldSize!, length: 2)
        self.snake!.stream().take(1).subscribe { (e: Packet<SnakeState?>) in
            if let snakeState = e.value {
                self.apple = Apple(worldSize: self.worldSize!, pointsToAvoid: snakeState!.snake)
                
                Streams.combineLatest(self.snake!.stream(), self.apple!.stream()).subscribe {
                    (e: Packet<(SnakeState?, AppleState?)>) in
                    var snakeState = e.value?.0
                    var appleState = e.value?.1
                    
                    if snakeState!.dead == true {
                        self.state.value = GameState(worldSize: self.worldSize!, snake: snakeState!.snake, apple:appleState!.location, end: true)                    }
                    else {
                        let head = snakeState!.snake[0]
                        if head.x == appleState!.location.x &&
                            head.y == appleState!.location.y {
                                self.snake!.tell(.Grow(2))
                                self.apple?.tell(AppleEvent.Move(self.worldSize!, snakeState!.snake))
                        }
                        
                        self.state.value = GameState(worldSize: self.worldSize!, snake: snakeState!.snake, apple:appleState!.location, end: false)
                    }
                }
            }
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    private func end() {
        self.timer!.invalidate()
        self.timer = nil
    }}