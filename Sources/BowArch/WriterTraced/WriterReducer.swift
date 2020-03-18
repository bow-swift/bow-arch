import Bow
import BowEffects

public typealias EffectWriterTReducer<Eff: Async & UnsafeRun, M: Monad, Environment, State: Monoid, Input> = EffectReducer<Eff, WriterTPartial<M, State>, Environment, Input>
public typealias EffectWriterReducer<Eff: Async & UnsafeRun, Environment, State: Monoid, Input> = EffectWriterTReducer<Eff, ForId, Environment, State, Input>
