import Bow
import BowOptics
import BowEffects

public typealias EffectStateTDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, S, Input> = EffectDispatcher<Eff, StateTPartial<M, S>, Environment, Input>
public typealias EffectStateDispatcher<Eff: Async & UnsafeRun, Environment, S, Input> = EffectStateTDispatcher<Eff, ForId, Environment, S, Input>
