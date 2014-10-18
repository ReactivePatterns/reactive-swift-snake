import Foundation

public protocol StateSubject {
    typealias E
    typealias S
    
    func tell(event:E)
    func stream() -> Stream<S?>
}

