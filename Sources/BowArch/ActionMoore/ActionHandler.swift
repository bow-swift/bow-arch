import Bow
import BowEffects

public typealias EffectActionHandler<Eff: Async, Action, Input> = EffectHandler<Eff, ActionPartial<Action>, Input>

//public extension EffectActionHandler {
//    func focus<AA, A>(_ f: @escaping (AA) -> A)
//        -> EffectActionHandler<Eff, AA, Input>
//        where M == ActionPartial<A> {
//            
//        EffectActionHandler(
//            { eff in
//                eff.map { action in
//                    action^.mapAction(f)
//                }^
//            } >>> self.handle
//        )
//    }
//}
