import Bow
import BowEffects

public class EffectHandler<Eff: Async, M: Monad, Input> {
    private let f: (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>
    
    public init(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) {
        self.f = f
    }
    
    public func handle(_ eff: Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void> {
        f(eff)
    }
    
    public func noOp() -> Kind<Eff, [Input]> {
        send(action: .pure(()))
    }
    
    public func send(action: Kind<M, Void>) -> Kind<Eff, [Input]> {
        send(effect: Eff.pure(action))
    }
    
    public func send(effect: Kind<Eff, Kind<M, Void>>) -> Kind<Eff, [Input]> {
        handle(effect).as([])
    }
}
