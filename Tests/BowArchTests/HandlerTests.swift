import XCTest
import Bow
import BowEffects
import BowOptics
import BowArch

class HandlerTests: XCTestCase {
    func handler(ref: IORef<Error, Int>) -> StateHandler<Int> {
        StateHandler { effect in
            effect.flatMap { action in
                ref.update { x in
                    action^.runS(x)
                }
            }
        }
    }
    
    func testHandler() {
        let ref = IORef<Error, Int>.unsafe(0)
        let sut = handler(ref: ref)
        try! sut.handle(Task.pure(.modify { $0 + 1 }))^.unsafeRunSync()
        let result = try! ref.get()^.unsafeRunSync()
        
        XCTAssertEqual(result, 1)
    }
}
