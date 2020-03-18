import Bow
import BowEffects

public typealias EffectWriterTHandler<Eff: Async, M: Monad, Environment, State: Monoid, Input> = EffectHandler<Eff, WriterTPartial<M, State>, Environment, Input>
public typealias EffectWriterHandler<Eff: Async, Environment, State: Monoid, Input> = EffectWriterTHandler<Eff, ForId, Environment, State, Input>
