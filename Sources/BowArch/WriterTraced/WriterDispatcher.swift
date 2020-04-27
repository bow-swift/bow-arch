import Bow
import BowEffects

public typealias EffectWriterTDispatcher<Eff: Async & UnsafeRun, M: Monad, State: Monoid, Input> = EffectDispatcher<Eff, WriterTPartial<M, State>, Input>
public typealias EffectWriterDispatcher<Eff: Async & UnsafeRun, State: Monoid, Input> = EffectWriterTDispatcher<Eff, ForId, State, Input>
