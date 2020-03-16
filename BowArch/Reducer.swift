import Bow
import BowEffects

public struct EffectReducer<Eff: Async & UnsafeRun, M: Monad, Environment, Input> {
    private let f: (Input, EffectHandler<Eff, M, Environment, Input>) -> Kleisli<Eff, Environment, [Input]>
    
    public init(from f: @escaping (Input, EffectHandler<Eff, M, Environment, Input>) -> Kleisli<Eff, Environment, [Input]>) {
        self.f = f
    }
    
    public func reduce(
        _ input: Input,
        _ handler: EffectHandler<Eff, M, Environment, Input>
    ) -> Kleisli<Eff, Environment, [Input]> {
        self.f(input, handler)
    }
}
