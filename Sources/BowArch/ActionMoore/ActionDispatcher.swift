import Bow
import BowEffects

public typealias EffectActionDispatcher<Eff: Async & UnsafeRun, Environment, Action, Input> = EffectDispatcher<Eff, ActionPartial<Action>, Environment, Input>
