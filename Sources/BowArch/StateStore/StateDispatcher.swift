import Bow
import BowOptics
import BowEffects

public typealias EffectStateTDispatcher<Eff: Async & UnsafeRun, M: Monad, E, S, I> = EffectDispatcher<Eff, StateTPartial<M, S>, E, I>
public typealias EffectStateDispatcher<Eff: Async & UnsafeRun, E, S, I> = EffectStateTDispatcher<Eff, ForId, E, S, I>

public extension EffectStateDispatcher {
    func widen<S1, S2, I2, E2>(
        transformEnvironment f: @escaping (E2) -> E,
        transformState lens: Lens<S2, S1>,
        transformInput prism: Prism<I2, I>
    ) -> EffectStateDispatcher<Eff, E2, S2, I2>
    where M == StatePartial<S1> {
        self.widen(f, { state in state^.focus(lens) }, prism.getOptional)
    }
}

//public extension EffectStateTDispatcher {
//    func lift<S1, S2, E2, I2, MM: Monad>(
//        _ transformEnvironment: @escaping (E2) -> Environment,
//        _ transformState: Lens<S2, S1>,
//        _ transformInput: @escaping (I2) -> Input?
//    ) -> EffectStateTDispatcher<Eff, MM, E2, S2, I2>
//    where M == StateTPartial<MM, S1> {
//        self.lift(
//            transformEnvironment,
//            { state in state^.focus(transformState) },
//            transformInput)
//    }
//}
