import Bow
import BowEffects

typealias EffectActionDispatcher<Eff: Async & UnsafeRun, E, Action, Input> = EffectDispatcher<Eff, ActionPartial<Action>, E, Input>
