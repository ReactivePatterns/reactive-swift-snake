import Foundation

public struct WorldSize {
    var width:Int
    var height:Int
}

public struct Point {
    var x:Int
    var y:Int
}

public enum Direction: Int {
    case left = 1
    case right = 2
    case up = 3
    case down = 4
    
    func canChangeTo(newDirection:Direction) -> Bool {
        var canChange = false
        switch self {
        case .left, .right:
            canChange = newDirection == .up || newDirection == .down
        case .up, .down:
            canChange = newDirection == .left || newDirection == .right
        }
        return canChange
    }
    
    func move(point:Point, worldSize:WorldSize) -> (Point) {
        var theX = point.x
        var theY = point.y
        switch self {
        case .left:
            if --theX < 0 {
                theX = worldSize.width - 1
            }
        case .up:
            if --theY < 0 {
                theY = worldSize.height - 1
            }
        case .right:
            if ++theX > worldSize.width {
                theX = 0
            }
        case .down:
            if ++theY > worldSize.height {
                theY = 0
            }
        }
        return Point(x: theX, y: theY)
    }
}

