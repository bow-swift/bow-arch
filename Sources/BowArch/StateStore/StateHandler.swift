import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, State> = EffectHandler<Eff, StateTPartial<M, State>>
public typealias EffectStateHandler<Eff: Async, State> = EffectStateTHandler<Eff, ForId, State>

public extension EffectStateTHandler {
    func focus<MM: Monad, S, SS>(
        _ lens: Lens<SS, S>
    ) -> EffectStateTHandler<Eff, MM, S>
        where M == StateTPartial<MM, SS> {
        self.lift { state in
            state^.focus(lens)
        }
    }
}
