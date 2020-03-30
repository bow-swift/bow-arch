import Bow
import BowEffects
import SwiftUI

public typealias ComponentView<W: Comonad, M: Monad, V: View> = EffectComponentView<IOPartial<Error>, W, M, V>

// MARK: State-Store

public typealias StateTHandler<M: Monad, Environment, State, Input> = EffectStateTHandler<IOPartial<Error>, M, Environment, State, Input>
public typealias StateHandler<Environment, State, Input> = EffectStateHandler<IOPartial<Error>, Environment, State, Input>

public typealias StateTDispatcher<M: Monad, Environment, State, Input> = EffectStateTDispatcher<IOPartial<Error>, M, Environment, State, Input>
public typealias StateDispatcher<Environment, State, Input> = EffectStateDispatcher<IOPartial<Error>, Environment, State, Input>

public typealias StoreTComponent<W: Comonad, M: Monad, S, V: View> = EffectStoreTComponent<IOPartial<Error>, W, M, S, V>
public typealias StoreComponent<S, V: View> = EffectStoreComponent<IOPartial<Error>, S, V>

// MARK: Writer-Traced

public typealias WriterTHandler<M: Monad, Environment, State: Monoid, Input> = EffectWriterTHandler<IOPartial<Error>, M, Environment, State, Input>
public typealias WriterHandler<Environment, State: Monoid, Input> = EffectWriterHandler<IOPartial<Error>, Environment, State, Input>

public typealias WriterTDispatcher<M: Monad, Environment, State: Monoid, Input> = EffectWriterTDispatcher<IOPartial<Error>, M, Environment, State, Input>
public typealias WriterDispatcher<Environment, State: Monoid, Input> = EffectWriterDispatcher<IOPartial<Error>, Environment, State, Input>

public typealias TracedTComponent<W: Comonad, M: Monad, State: Monoid, V: View> = EffectTracedTComponent<IOPartial<Error>, W, M, State, V>
public typealias TracedComponent<State: Monoid, V: View> = EffectTracedComponent<IOPartial<Error>, State, V>

// MARK: Action-Moore

public typealias ActionHandler<Environment, Action, Input> = EffectActionHandler<IOPartial<Error>, Environment, Action, Input>

public typealias ActionDispatcher<Environment, Action, Input> = EffectActionDispatcher<IOPartial<Error>, Environment, Action, Input>

public typealias MooreComponent<Action, V: View> = EffectMooreComponent<IOPartial<Error>, Action, V>
