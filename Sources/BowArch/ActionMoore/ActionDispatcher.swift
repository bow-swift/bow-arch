import Bow
import BowEffects

public typealias EffectActionDispatcher<Eff: Async & UnsafeRun, Environment, Action, Input> = EffectDispatcher<Eff, ActionPartial<Action>, Environment, Input>

public extension EffectActionDispatcher where M == ActionPartial<Input> {
    static func `default`() -> EffectActionDispatcher<Eff, Environment, Input, Input> {
        EffectActionDispatcher { input, handler in
            Kleisli { _ in handler.send(action: Action.from(input)) }
        }
    }
}
