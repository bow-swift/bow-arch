import Bow
import BowEffects

public typealias EffectWriterTDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, State: Monoid, Input> = EffectDispatcher<Eff, WriterTPartial<M, State>, Environment, Input>
public typealias EffectWriterDispatcher<Eff: Async & UnsafeRun, Environment, State: Monoid, Input> = EffectWriterTDispatcher<Eff, ForId, Environment, State, Input>
