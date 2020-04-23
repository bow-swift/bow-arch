import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Input>
public typealias EffectStateHandler<Eff: Async, State, Input> = EffectStateTHandler<Eff, ForId, State, Input>

//public extension EffectStateTHandler {
//    func focus<MM: Monad, S, SS>(
//        _ lens: Lens<SS, S>
//    ) -> EffectStateTHandler<Eff, MM, S, Input>
//        where M == StateTPartial<MM, SS> {
//        EffectStateTHandler(
//            { eff in
//                eff.map { state in
//                    state^.focus(lens)
//                }^
//            } >>> self.handle
//        )
//    }
//}
