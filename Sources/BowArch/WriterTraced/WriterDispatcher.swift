import Bow
import BowEffects

typealias EffectWriterTDispatcher<Eff: Async & UnsafeRun, M: Monad, State: Monoid, Input> = EffectDispatcher<Eff, WriterTPartial<M, State>, Input>
typealias EffectWriterDispatcher<Eff: Async & UnsafeRun, State: Monoid, Input> = EffectWriterTDispatcher<Eff, ForId, State, Input>
