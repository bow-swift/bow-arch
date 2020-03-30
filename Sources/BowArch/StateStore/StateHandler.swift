import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, Environment, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Environment, Input>
public typealias EffectStateHandler<Eff: Async, Environment, State, Input> = EffectStateTHandler<Eff, ForId, Environment, State, Input>

public extension EffectStateTHandler {
    func focus<MM: Monad, S, SS>(
        _ lens: Lens<SS, S>
    ) -> EffectStateTHandler<Eff, MM, Environment, S, Input>
        where M == StateTPartial<MM, SS> {
        EffectStateTHandler(
            { eff in
                eff.map { state in
                    state^.focus(lens)
                }^
            } >>> self.handle
        )
    }
}
