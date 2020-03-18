import Bow
import BowEffects
import SwiftUI

public typealias ComponentView<W: Comonad, M: Monad, V: View> = EffectComponentView<IOPartial<Error>, W, M, V>

// MARK: State-Store

public typealias StateTHandler<M: Monad, Environment, State, Input> = EffectStateTHandler<IOPartial<Error>, M, Environment, State, Input>
public typealias StateHandler<Environment, State, Input> = EffectStateHandler<IOPartial<Error>, Environment, State, Input>

public typealias StateTReducer<M: Monad, Environment, State, Input> = EffectStateTReducer<IOPartial<Error>, M, Environment, State, Input>
public typealias StateReducer<Environment, State, Input> = EffectStateReducer<IOPartial<Error>, Environment, State, Input>

public typealias StoreTComponent<W: Comonad, M: Monad, S, V: View> = EffectStoreTComponent<IOPartial<Error>, W, M, S, V>
public typealias StoreComponent<S, V: View> = EffectStoreComponent<IOPartial<Error>, S, V>

// MARK: Writer-Traced

public typealias WriterTHandler<M: Monad, Environment, State: Monoid, Input> = EffectWriterTHandler<IOPartial<Error>, M, Environment, State, Input>
public typealias WriterHandler<Environment, State: Monoid, Input> = EffectWriterHandler<IOPartial<Error>, Environment, State, Input>

public typealias WriterTReducer<M: Monad, Environment, State: Monoid, Input> = EffectWriterTReducer<IOPartial<Error>, M, Environment, State, Input>
public typealias WriterReducer<Environment, State: Monoid, Input> = EffectWriterReducer<IOPartial<Error>, Environment, State, Input>

public typealias TracedTComponent<W: Comonad, M: Monad, State: Monoid, V: View> = EffectTracedTComponent<IOPartial<Error>, W, M, State, V>
public typealias TracedComponent<State: Monoid, V: View> = EffectTracedComponent<IOPartial<Error>, State, V>
