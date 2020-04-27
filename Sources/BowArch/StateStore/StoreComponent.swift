import SwiftUI
import Bow
import BowEffects
import BowOptics

public typealias EffectStoreTComponent<Eff: Async & UnsafeRun, WW: Comonad, MM: Monad, S, I, V: View> = EffectComponentView<Eff, StoreTPartial<S, WW>, StateTPartial<MM, S>, I, V>
public typealias EffectStoreComponent<Eff: Async & UnsafeRun, S, I, V: View> = EffectStoreTComponent<Eff, ForId, ForId, S, I, V>

private class StateFunction<S1, S2>: FunctionK<StatePartial<S1>, StatePartial<S2>> {
    let lens: Lens<S2, S1>
    
    init(_ lens: Lens<S2, S1>) {
        self.lens = lens
    }
    
    override func invoke<A>(_ fa: StateOf<S1, A>) -> StateOf<S2, A> {
        fa^.focus(lens)
    }
}

private class StoreFunction<S1, S2>: FunctionK<StoreTPartial<S1, ForId>, StoreTPartial<S2, ForId>> {
    let state: S2
    let g: (S2) -> S1
    
    init(_ state: S2, _ g: @escaping (S2) -> S1) {
        self.state = state
        self.g = g
    }
    
    override func invoke<A>(_ fa: StoreOf<S1, A>) -> StoreOf<S2, A> {
        Store(state) { s2 in
            fa^.render^.value(self.g(s2))
        }
    }
}

extension EffectComponent {
    func lift<S1, S2>(
        _ state: S2,
        _ lens: Lens<S2, S1>
    ) -> EffectComponent<Eff, StorePartial<S2>, StatePartial<S2>, A>
    where M == StatePartial<S1>,
          W == StorePartial<S1> {
        self.lift(StoreFunction<S1, S2>(state, { s in lens.get(s) }),
                  StateFunction<S1, S2>(lens),
                  Pairing.pairStateStore())
    }
}

public extension EffectStoreComponent {
    init<S>(
        initialState: S,
        dispatcher: EffectDispatcher<Eff, M, I>,
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) where M == StatePartial<S>,
            W == StorePartial<S> {
        self.init(dispatcher) { dispatcher in
            EffectComponent(
                Store(initialState) { state in
                    UI { handler in
                        render(state, dispatcher.dispatch(to: handler))
                    }
                },
            Pairing.pairStateStore())
        }
    }
    
    func scope<S1, S2, I2>(
        state: S2,
        dispatcher: EffectStateDispatcher<Eff, S2, I2>,
        handler: EffectStateHandler<Eff, S2>,
        lens: Lens<S2, S1>,
        prism: Prism<I2, I>
    ) -> EffectStoreComponent<Eff, S2, I2, V>
    where M == StatePartial<S1>,
          W == StorePartial<S1> {
        EffectStoreComponent<Eff, S2, I2, V>(
            self.dispatcher.scope(prism.getOptional, lens).combine(dispatcher),
            
            { dispatcher in
                self.makeComponent(
                    EffectStateDispatcher { input in
                        dispatcher.on(prism.reverseGet(input)).map { eff in
                            eff.map { _ in
                                .modify { $0 }
                            }
                        }
                    }
                ).lift(state, lens).handling(with: handler)
            }
        )
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
    func store<S>() -> Store<S, UI<Eff, M, V>>
        where M == StatePartial<S>,
              W == StorePartial<S> {
        self.component.wui^
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
