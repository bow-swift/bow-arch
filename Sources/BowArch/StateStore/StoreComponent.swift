import SwiftUI
import Bow
import BowEffects
import BowOptics

public typealias EffectStoreTComponent<Eff: Async, WW: Comonad, MM: Monad, S, V: View> = EffectComponentView<Eff, StoreTPartial<S, WW>, StateTPartial<MM, S>, V>
//public typealias EffectStoreComponent<Eff: Async, S, V: View> = EffectStoreTComponent<Eff, ForId, ForId, S, V>

public struct EffectStoreComponent<Eff: Async & UnsafeRun, E, S, I, V: View>: View {
    private let initialState: S
    private let environment: E
    private let dispatcher: EffectStateDispatcher<Eff, E, S, I>
    private let render: (S, @escaping (I) -> Void) -> V
    private let component: EffectComponentView<Eff, StorePartial<S>, StatePartial<S>, V>
    
    public init(
        initialState: S,
        environment: E,
        dispatcher: EffectStateDispatcher<Eff, E, S, I>,
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) {
        self.initialState = initialState
        self.environment = environment
        self.dispatcher = dispatcher
        self.render = render
        self.component = EffectComponentView(
            EffectComponent(
                Store(initialState) { state in
                    UI { handler in
                        render(state) { i in
                            dispatcher.sendingTo(handler, environment: environment)(i)
                        }
                    }
                },
            Pairing.pairStateStore()))
    }
    
    public var body: some View {
        self.component
    }
    
//    init<E, A, I, WW: Comonad & Applicative, MM: Monad>(
//        initialState: A,
//        environment: E,
//        pairing: Pairing<MM, WW>,
//        render: @escaping (A, EffectStateTHandler<Eff, MM, A, I>) -> V)
//        where W == StoreTPartial<A, WW>,
//              M == StateTPartial<MM, A> {
//        self.init(StoreT(initialState, WW.pure({ state in
//            UI { send in
//                render(state,
//                       EffectStateTHandler(send))
//            }
//        })), pairing)
//    }
//
//    init<A, WW: Comonad & Applicative, MM: Monad, I>(
//        initialState: A,
//        pairing: Pairing<MM, WW>,
//        render: @escaping (A, EffectStateTHandler<Eff, MM, A, I>) -> V)
//        where W == StoreTPartial<A, WW>,
//              M == StateTPartial<MM, A> {
//        self.init(initialState: initialState,
//                  environment: (),
//                  pairing: pairing,
//                  render: render)
//    }
}

public extension EffectStoreComponent {
//    init<E, A, I>(initialState: A,
//                  environment: E,
//                  render: @escaping (A, EffectStateHandler<Eff, A, I>) -> V)
//        where W == StorePartial<A>,
//              M == StatePartial<A> {
//        self.init(Store(initialState) { state in
//            UI { send in
//                render(state, EffectStateHandler(send))
//            }
//        })
//    }
//    
//    init<A, I>(initialState: A,
//               render: @escaping (A, EffectStateHandler<Eff, A, I>) -> V)
//        where W == StorePartial<A>,
//              M == StatePartial<A> {
//        self.init(initialState: initialState,
//                  environment: (),
//                  render: render)
//    }
}

public extension EffectStoreTComponent {
    func storeT<A, WW: Comonad, MM: Monad>() -> StoreT<A, WW, UI<Eff, M, V>>
        where W == StoreTPartial<A, WW>,
              M == StateTPartial<MM, A> {
        self.component.wui^
    }
}

public extension EffectStoreComponent {
    func store() -> Store<S, UI<Eff, StatePartial<S>, V>> {
        self.component.component.wui^
    }
}

//public extension EffectStoreTComponent {
//    func lift<A, B, WW: Comonad, MM: Monad, Environment, Input>(
//        _ handler: EffectStateTHandler<Eff, MM, B, Input>,
//        _ lens: Lens<B, A>
//    ) -> EffectStoreTComponent<Eff, WW, MM, A, V>
//        where W == StoreTPartial<A, WW>,
//              M == StateTPartial<MM, A> {
//
//        EffectStoreTComponent(self.component.lift(handler.focus(lens)))
//    }
//}
