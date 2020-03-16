import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, Environment, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Environment, Input>
public typealias EffectStateHandler<Eff: Async, Environment, State, Input> = EffectStateTHandler<Eff, ForId, Environment, State, Input>

public extension EffectStateTHandler {
    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment, LocalInput>(
        _ getter: Getter<Environment, LocalEnvironment>,
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        EffectStateTHandler(
            { eff in eff.map { state in state^.focus(lens) }^ } >>> self.handle
        ).map(getter.get)
    }
}
