import SwiftUI
import Bow
import BowEffects

public typealias EffectMooreComponent<Eff: Async, Action, V: View> = EffectComponentView<Eff, MoorePartial<Action>, ActionPartial<Action>, V>

public extension EffectMooreComponent {
    init<E, A, S, I>(
        initialState: S,
        environment: E,
        reducer: Reducer<S, A>,
        render: @escaping (S, EffectActionHandler<Eff, E, A, I>) -> V)
        where W == MoorePartial<A>,
              M == ActionPartial<A> {
    self.init(Moore.from(
        initialState: initialState,
        render: { state in
            UI { send in
                render(state, EffectActionHandler(send, environment: environment))
            }
    },
        update: reducer.run))
    }
}
