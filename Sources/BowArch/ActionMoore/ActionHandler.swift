import Bow
import BowEffects

public typealias EffectActionHandler<Eff: Async, Environment, Action, Input> = EffectHandler<Eff, ActionPartial<Action>, Environment, Input>
