import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, Environment, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Environment, Input>
public typealias EffectStateHandler<Eff: Async, Environment, State, Input> = EffectStateTHandler<Eff, ForId, Environment, State, Input>
