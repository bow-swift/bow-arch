import Bow
import BowOptics
import BowEffects

public typealias EffectStateTReducer<Eff: Async & UnsafeRun, M: Monad, Environment, S, Input> = EffectReducer<Eff, StateTPartial<M, S>, Environment, Input>
public typealias EffectStateReducer<Eff: Async & UnsafeRun, Environment, S, Input> = EffectStateTReducer<Eff, ForId, Environment, S, Input>

public extension EffectStateTReducer {
    func focus<MM: Monad, GlobalState, LocalState, GlobalEnvironment, GlobalInput>(
        _ getter: Getter<GlobalEnvironment, Environment>,
        _ lens: Lens<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTReducer<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        EffectStateTReducer<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput> { input, handler in
            if let newInput = prism.getOptional(input) {
                return self.reduce(newInput, handler.focus(getter, lens)).map { array in
                    array.map(prism.reverseGet)
                    }^.contramap(getter.get)
            } else {
                return Kleisli.pure([])^
            }
        }
    }
}
