import Foundation

public enum AppleEvent {
    case Move(WorldSize, [Point])
}

public struct AppleState {
    var location: Point
}

public class Apple: StateSubject {
    public typealias E = AppleEvent
    public typealias S = AppleState
    
    private let state = Subject<AppleState?>(nil)
    
    init(worldSize:WorldSize, pointsToAvoid: [Point]) {
        self.tell(.Move(worldSize, pointsToAvoid))
    }
    
    public func tell(e:AppleEvent) {
        switch e {
            case .Move(let worldSize, let pointsToAvoid):
                self.move(worldSize, pointsToAvoid: pointsToAvoid)
            default:
                ()
        }
    }
    
    public func stream() -> Stream<AppleState?> {
        return self.state.unwrap
    }
     
    private func move(worldSize:WorldSize, pointsToAvoid: [Point]) {
        self.state.value = AppleState(location: self.newLocation(worldSize, pointsToAvoid: pointsToAvoid))
    }
    
    private func newLocation(worldSize:WorldSize, pointsToAvoid: [Point]) -> Point {
        srandomdev()
        var x = 0, y = 0
        while (true) {
            x = random() % worldSize.width
            y = random() % worldSize.height
            var isBody = false
            for p in pointsToAvoid {
                if p.x == x && p.y == y {
                    isBody = true
                    break
                }
            }
            if !isBody {
                break
            }
        }
        return Point(x: x, y: y)
    }

}