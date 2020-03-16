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
}
