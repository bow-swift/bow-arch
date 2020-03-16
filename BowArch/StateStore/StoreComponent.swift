import SwiftUI
import Bow
import BowEffects

public typealias EffectStoreTComponent<Eff: Async, WW: Comonad, MM: Monad, S, V: View> = EffectComponentView<Eff, StoreTPartial<S, WW>, StateTPartial<MM, S>, V>
public typealias EffectStoreComponent<Eff: Async, S, V: View> = EffectStoreTComponent<Eff, ForId, ForId, S, V>

public extension EffectStoreTComponent {
    init<E, A, I, WW: Comonad & Applicative, MM: Monad>(
        initialState: A,
        environment: E,
        pairing: Pairing<MM, WW>,
        render: @escaping (A, EffectStateTHandler<Eff, MM, E, A, I>) -> V)
        where W == StoreTPartial<A, WW>,
              M == StateTPartial<MM, A> {
        self.init(StoreT(initialState, WW.pure({ state in
            UI { send in
                render(state, EffectStateTHandler(send).map(constant(environment)))
            }
        })), pairing)
    }
    
    init<A, WW: Comonad & Applicative, MM: Monad, I>(
        initialState: A,
        pairing: Pairing<MM, WW>,
        render: @escaping (A, EffectStateTHandler<Eff, MM, Any, A, I>) -> V)
        where W == StoreTPartial<A, WW>,
              M == StateTPartial<MM, A> {
        self.init(initialState: initialState,
                  environment: () as Any,
                  pairing: pairing,
                  render: render)
    }
}
