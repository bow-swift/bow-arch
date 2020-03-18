import SwiftUI
import Bow
import BowEffects

public typealias EffectTracedTComponent<Eff: Async, WW: Comonad, MM: Monad, State: Monoid, V: View> = EffectComponentView<Eff, TracedTPartial<State, WW>, WriterTPartial<MM, State>, V>
public typealias EffectTracedComponent<Eff: Async, State: Monoid, V: View> = EffectTracedTComponent<Eff, ForId, ForId, State, V>

public extension EffectTracedTComponent {
    init<Environment, State: Monoid, Input, WW: Comonad & Applicative, MM: Monad>(
        environment: Environment,
        pairing: Pairing<MM, WW>,
        render: @escaping (State, EffectWriterTHandler<Eff, MM, Environment, State, Input>) -> V
    ) where W == TracedTPartial<State, WW>,
            M == WriterTPartial<MM, State> {
        self.init(TracedT(WW.pure({ state in
            UI { send in
                render(state,
                       EffectWriterTHandler(send).map(constant(environment)))
            }
        })), pairing)
    }
}

public extension EffectTracedComponent {
    init<Environment, State: Monoid, Input>(
        environment: Environment,
        render: @escaping (State, EffectWriterHandler<Eff, Environment, State, Input>) -> V)
        where W == TracedPartial<State>,
              M == WriterPartial<State> {
                self.init(Traced { state in
                    UI { send in
                        render(state, EffectWriterHandler(send).map(constant(environment)))
                    }
                })
    }
}
