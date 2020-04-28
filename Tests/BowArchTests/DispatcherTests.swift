import XCTest
import Bow
import BowEffects
import BowArch
import BowOptics

class DispatcherTests: XCTestCase {
    enum TestAction {
        case increment
        case decrement
    }
    
    enum ParentAction: AutoPrism {
        case test(TestAction)
        case other
    }
    
    struct Count: Equatable {
        let count: Int
        
        static var lens: Lens<Count, Int> {
            Lens(get: { $0.count }, set: { Count(count: $1) })
        }
    }
    
    let dispatcher = StateDispatcher<Int, TestAction>.pure { input in
        switch input {
        case .increment: return .modify { x in x + 1 }
        case .decrement: return .modify { x in x - 1 }
        }
    }
    
    let noOp = StateDispatcher<Int, TestAction>.pure { _ in .modify(id) }
    
    func testDispatcher() {
        let result = run(actions: dispatcher.on(.increment), initial: 0)
        
        XCTAssertEqual(result, 1)
    }
    
    func testLiftDispatcher() {
        let lifted = dispatcher.scope(
            ParentAction.prism(for: ParentAction.test).getOptional,
            Count.lens
        )
        
        let result = run(actions: lifted.on(.test(.increment)), initial: Count(count: 0))
        XCTAssertEqual(result, Count(count: 1))
        
        let result2 = run(actions: lifted.on(.other), initial: Count(count: 0))
        XCTAssertEqual(result2, Count(count: 0))
    }
    
    func testCombination() {
        let combined = noOp.combine(dispatcher)
        let result = run(actions: combined.on(.increment), initial: 0)
        XCTAssertEqual(result, 1)
        
        let reversed = dispatcher.combine(noOp)
        let result2 = run(actions: reversed.on(.increment), initial: 0)
        XCTAssertEqual(result2, 1)
    }
    
    func testEmpty() {
        let empty = StateDispatcher<Int, TestAction>.empty()
        let result = run(actions: empty.on(.increment), initial: 0)
        XCTAssertEqual(result, 0)
    }
    
    func run<S>(actions: [IOOf<Error, StateOf<S, Void>>], initial: S) -> S {
        actions.reduce(initial) { result, next in
            try! next^.map { action in
                action^.runS(result)
            }^.unsafeRunSync()
        }
    }
    
    func testPrism() {
        
    }
}
