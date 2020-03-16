import Bow
import BowEffects
import SwiftUI

public typealias StateTHandler<M: Monad, Environment, State, Input> = EffectStateTHandler<IOPartial<Error>, M, Environment, State, Input>
public typealias StateHandler<Environment, State, Input> = EffectStateHandler<IOPartial<Error>, Environment, State, Input>

public typealias StateTReducer<M: Monad, Environment, State, Input> = EffectStateTReducer<IOPartial<Error>, M, Environment, State, Input>
public typealias StateReducer<Environment, State, Input> = EffectStateReducer<IOPartial<Error>, Environment, State, Input>

public typealias StoreTComponent<W: Comonad, M: Monad, S, V: View> = EffectStoreTComponent<IOPartial<Error>, W, M, S, V>
public typealias StoreComponent<S, V: View> = EffectStoreComponent<IOPartial<Error>, S, V>

public typealias ComponentView<W: Comonad, M: Monad, V: View> = EffectComponentView<IOPartial<Error>, W, M, V>
