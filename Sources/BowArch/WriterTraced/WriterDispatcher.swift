import Bow
import BowEffects

typealias EffectWriterTDispatcher<Eff: Async & UnsafeRun, M: Monad, E, State: Monoid, Input> = EffectDispatcher<Eff, WriterTPartial<M, State>, E, Input>
typealias EffectWriterDispatcher<Eff: Async & UnsafeRun, E, State: Monoid, Input> = EffectWriterTDispatcher<Eff, ForId, E, State, Input>
