import Bow
import BowEffects

public class EffectHandler<Eff: Async, M: Monad, Environment, Input> {
    private let f: (Kleisli<Eff, Environment, Kind<M, Void>>) -> Kind<Eff, Void>
    
    public init(_ f: @escaping (Kleisli<Eff, Environment, Kind<M, Void>>) -> Kind<Eff, Void>) {
        self.f = f
    }
    
    public func handle(_ env: Kleisli<Eff, Environment, Kind<M, Void>>) -> Kind<Eff, Void> {
        f(env)
    }
    
    public func map<LocalEnvironment>(_ f: @escaping (Environment) -> LocalEnvironment) -> EffectHandler<Eff, M, LocalEnvironment, Input> {
        EffectHandler<Eff, M, LocalEnvironment, Input> { kleisli in
            self.f(kleisli.contramap(f))
        }
    }
    
    public func noOp() -> Kleisli<Eff, Environment, [Input]> {
        send(action: .pure(()))
    }
    
    public func send(action: Kind<M, Void>) -> Kleisli<Eff, Environment, [Input]> {
        send(effect: Eff.pure(action))
    }
    
    public func send(effect: Kind<Eff, Kind<M, Void>>) -> Kleisli<Eff, Environment, [Input]> {
        send(effect: Kleisli { _ in effect })
    }
    
    public func send(effect: Kleisli<Eff, Environment, Kind<M, Void>>) -> Kleisli<Eff, Environment, [Input]> {
        Kleisli { _ in self.handle(effect).as([]) }
    }
}

public extension EffectHandler where Environment == Any {
    convenience init(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) {
        self.init { kleisli in f(kleisli.run(())) }
    }
}