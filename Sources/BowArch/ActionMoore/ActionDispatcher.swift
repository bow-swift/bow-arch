import Bow
import BowEffects

typealias EffectActionDispatcher<Eff: Async & UnsafeRun, Action, Input> = EffectDispatcher<Eff, ActionPartial<Action>, Input>
