import Bow
import BowEffects

public typealias EffectWriterTHandler<Eff: Async, M: Monad, State: Monoid> = EffectHandler<Eff, WriterTPartial<M, State>>
public typealias EffectWriterHandler<Eff: Async, State: Monoid> = EffectWriterTHandler<Eff, ForId, State>
