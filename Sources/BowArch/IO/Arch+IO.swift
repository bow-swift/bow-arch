import Bow
import BowEffects
import SwiftUI

public typealias ComponentView<W: Comonad, M: Monad, I, V: View> = EffectComponentView<IOPartial<Error>, W, M, I, V>

// MARK: State-Store

public typealias StateTHandler<M: Monad, State> = EffectStateTHandler<IOPartial<Error>, M, State>
public typealias StateHandler<State> = EffectStateHandler<IOPartial<Error>, State>

public typealias StateTDispatcher<M: Monad, State, Input> = EffectStateTDispatcher<IOPartial<Error>, M, State, Input>
public typealias StateDispatcher<State, Input> = EffectStateDispatcher<IOPartial<Error>, State, Input>

//public typealias StoreTComponent<W: Comonad, M: Monad, S, I, V: View> = EffectStoreTComponent<IOPartial<Error>, W, M, S, I, V>
public typealias StoreComponent<S, I, V: View> = EffectStoreComponent<IOPartial<Error>, S, I, V>

// MARK: Writer-Traced

typealias WriterTHandler<M: Monad, State: Monoid> = EffectWriterTHandler<IOPartial<Error>, M, State>
typealias WriterHandler<State: Monoid> = EffectWriterHandler<IOPartial<Error>, State>

typealias WriterTDispatcher<M: Monad, State: Monoid, Input> = EffectWriterTDispatcher<IOPartial<Error>, M, State, Input>
typealias WriterDispatcher<Environment, State: Monoid, Input> = EffectWriterDispatcher<IOPartial<Error>, State, Input>

typealias TracedTComponent<W: Comonad, M: Monad, State: Monoid, I, V: View> = EffectTracedTComponent<IOPartial<Error>, W, M, State, I, V>
typealias TracedComponent<State: Monoid, I, V: View> = EffectTracedComponent<IOPartial<Error>, State, I, V>

// MARK: Action-Moore

typealias ActionHandler<Action> = EffectActionHandler<IOPartial<Error>, Action>

typealias ActionDispatcher<Environment, Action, Input> = EffectActionDispatcher<IOPartial<Error>, Action, Input>

typealias MooreComponent<Action, I, V: View> = EffectMooreComponent<IOPartial<Error>, Action, I, V>
