import Bow
import BowEffects

public class EffectHandler<Eff: Async, M: Monad> {
    private let f: (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>
    
    public init(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) {
        self.f = f
    }
    
    public func handle(_ eff: Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void> {
        f(eff)
    }
    
    public func noOp<E>() -> Kleisli<Eff, E, Void> {
        send(action: .pure(()))
    }
    
    public func send<E>(action: Kind<M, Void>) -> Kleisli<Eff, E, Void> {
        send(effect: .pure(action))
    }
    
    public func send<E>(effect: Kind<Eff, Kind<M, Void>>) -> Kleisli<Eff, E, Void> {
        Kleisli { _ in self.handle(effect) }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<MM, Void>) -> Kind<M, Void>) -> EffectHandler<Eff, MM> {
        EffectHandler<Eff, MM> { action in
            self.f(action.map(f))
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<Eff, Kind<MM, Void>>) -> Kind<Eff, Kind<M, Void>>) -> EffectHandler<Eff, MM> {
        EffectHandler<Eff, MM> { action in
            self.f(f(action))
        }
    }
}
