import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, State> = EffectHandler<Eff, StateTPartial<M, State>>
public typealias EffectStateHandler<Eff: Async, State> = EffectStateTHandler<Eff, ForId, State>

public extension EffectHandler {
    func narrow<S, S2>(
        _ lens: Lens<S, S2>
    ) -> EffectStateHandler<Eff, S2>
        where M == StatePartial<S> {
        self.lift { action in
            action^.focus(lens)
        }
    }
}
