import Bow
import BowEffects

public final class UI<Eff: Async, M: Monad, A> {
    let makeView: (EffectHandler<Eff, M>) -> A
    
    public init(_ makeView: @escaping (EffectHandler<Eff, M>) -> A) {
        self.makeView = makeView
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<M, Void>) -> Kind<MM, Void>) -> UI<Eff, MM, A> {
        UI<Eff, MM, A> { handler in
            self.makeView(handler.lift(f))
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Kind<MM, Void>>) -> UI<Eff, MM, A> {
        UI<Eff, MM, A> { handler in
            self.makeView(handler.lift(f))
        }
    }
    
    public func make(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) -> A {
        self.makeView(EffectHandler(f))
    }
}
