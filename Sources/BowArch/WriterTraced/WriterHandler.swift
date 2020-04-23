import Bow
import BowEffects

public typealias EffectWriterTHandler<Eff: Async, M: Monad, State: Monoid, Input> = EffectHandler<Eff, WriterTPartial<M, State>, Input>
public typealias EffectWriterHandler<Eff: Async, State: Monoid, Input> = EffectWriterTHandler<Eff, ForId, State, Input>
