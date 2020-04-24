import Bow
import BowOptics
import BowEffects

public typealias EffectStateTDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, S, Input> = EffectDispatcher<Eff, StateTPartial<M, S>, Environment, Input>
public typealias EffectStateDispatcher<Eff: Async & UnsafeRun, Environment, S, Input> = EffectStateTDispatcher<Eff, ForId, Environment, S, Input>

public extension EffectStateTDispatcher {
    func lift<S1, S2, E2, I2, MM: Monad>(
        _ transformEnvironment: @escaping (E2) -> Environment,
        _ transformState: Lens<S2, S1>,
        _ transformInput: @escaping (I2) -> Input?
    ) -> EffectStateTDispatcher<Eff, MM, E2, S2, I2>
    where M == StateTPartial<MM, S1> {
        self.lift(
            transformEnvironment,
            { state in state^.focus(transformState) },
            transformInput)
    }
}
