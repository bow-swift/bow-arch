import Bow
import BowOptics
import BowEffects

public typealias EffectStateTDispatcher<Eff: Async & UnsafeRun, M: Monad, E, S, I> = EffectDispatcher<Eff, StateTPartial<M, S>, E, I>
public typealias EffectStateDispatcher<Eff: Async & UnsafeRun, E, S, I> = EffectStateTDispatcher<Eff, ForId, E, S, I>

public extension EffectStateDispatcher {
    static func pure<S>(
        _ f: @escaping (I) -> State<S, Void>
    ) -> EffectDispatcher<Eff, M, E, I>
    where M == StatePartial<S> {
        .effectful { input in Kleisli { _ in Eff.pure(f(input)) } }
    }
    
    static func effectful<S>(
        _ f: @escaping (I) -> Kleisli<Eff, E, State<S, Void>>
    ) -> EffectDispatcher<Eff, M, E, I>
    where M == StatePartial<S> {
        .workflow { input in [f(input)] }
    }
    
    static func workflow<S>(
        _ f: @escaping (I) -> [Kleisli<Eff, E, State<S, Void>>]
    ) -> EffectDispatcher<Eff, M, E, I>
    where M == StatePartial<S> {
        EffectDispatcher { input in
            f(input).map { action in action.map(id)^ }
        }
    }
    
    func widen<S1, S2, I2, E2>(
        transformEnvironment f: @escaping (E2) -> E,
        transformState lens: Lens<S2, S1>,
        transformInput prism: Prism<I2, I>
    ) -> EffectStateDispatcher<Eff, E2, S2, I2>
    where M == StatePartial<S1> {
        self.widen(f, { state in state^.focus(lens) }, prism.getOptional)
    }
    
    func widen<S, E2>(
        transformEnvironment f: @escaping (E2) -> E
    ) -> EffectStateDispatcher<Eff, E2, S, I>
    where M == StatePartial<S> {
        self.widen(
            transformEnvironment: f,
            transformState: Lens.identity,
            transformInput: Prism.identity)
    }
    
    func widen<S1, S2>(
        transformState lens: Lens<S2, S1>
    ) -> EffectStateDispatcher<Eff, E, S2, I>
    where M == StatePartial<S1> {
        self.widen(
            transformEnvironment: id,
            transformState: lens,
            transformInput: Prism.identity)
    }
    
    func widen<S, I2>(
        transformInput prism: Prism<I2, I>
    ) -> EffectStateDispatcher<Eff, E, S, I2>
    where M == StatePartial<S> {
        self.widen(
            transformEnvironment: id,
            transformState: Lens.identity,
            transformInput: prism)
    }
    
    func widen<S1, S2, E2>(
        transformEnvironment f: @escaping (E2) -> E,
        transformState lens: Lens<S2, S1>
    ) -> EffectStateDispatcher<Eff, E2, S2, I>
    where M == StatePartial<S1> {
        self.widen(
            transformEnvironment: f,
            transformState: lens,
            transformInput: Prism.identity)
    }
    
    func widen<S, I2, E2>(
        transformEnvironment f: @escaping (E2) -> E,
        transformInput prism: Prism<I2, I>
    ) -> EffectStateDispatcher<Eff, E2, S, I2>
    where M == StatePartial<S> {
        self.widen(
            transformEnvironment: f,
            transformState: Lens.identity,
            transformInput: prism)
    }
    
    func widen<S1, S2, I2>(
        transformState lens: Lens<S2, S1>,
        transformInput prism: Prism<I2, I>
    ) -> EffectStateDispatcher<Eff, E, S2, I2>
    where M == StatePartial<S1> {
        self.widen(
            transformEnvironment: id,
            transformState: lens,
            transformInput: prism)
    }
}
