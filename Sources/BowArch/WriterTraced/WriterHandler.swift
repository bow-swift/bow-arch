import Bow
import BowEffects

typealias EffectWriterTHandler<Eff: Async, M: Monad, State: Monoid> = EffectHandler<Eff, WriterTPartial<M, State>>
typealias EffectWriterHandler<Eff: Async, State: Monoid> = EffectWriterTHandler<Eff, ForId, State>
