import Bow
import BowOptics
import BowEffects

public typealias EffectStateTReducer<Eff: Async & UnsafeRun, M: Monad, Environment, S, Input> = EffectReducer<Eff, StateTPartial<M, S>, Environment, Input>
public typealias EffectStateReducer<Eff: Async & UnsafeRun, Environment, S, Input> = EffectStateTReducer<Eff, ForId, Environment, S, Input>
