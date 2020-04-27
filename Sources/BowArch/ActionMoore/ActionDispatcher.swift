import Bow
import BowEffects

public typealias EffectActionDispatcher<Eff: Async & UnsafeRun, Action, Input> = EffectDispatcher<Eff, ActionPartial<Action>, Input>

//public extension EffectActionDispatcher where M == ActionPartial<Input> {
//    static func `default`() -> EffectActionDispatcher<Eff, Environment, Input, Input> {
//        EffectActionDispatcher { input, handler in
//            handler.send(action: Action.from(input))
//        }
//    }
//}
