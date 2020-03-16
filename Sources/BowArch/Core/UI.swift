import Bow
import BowEffects

public final class UI<Eff: Async, M: Monad, A> {
    let makeView: (@escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) -> A
    
    public init(_ makeView: @escaping (@escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) -> A) {
        self.makeView = makeView
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<M, Void>) -> Kind<MM, Void>) -> UI<Eff, MM, A> {
        UI<Eff, MM, A> { send in
            self.makeView { action in send(action.map(f)) }
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Kind<MM, Void>>) -> UI<Eff, MM, A> {
        UI<Eff, MM, A> { send in
            self.makeView { action in send(f(action)) }
        }
    }
}
