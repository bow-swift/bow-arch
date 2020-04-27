import SwiftUI
import Bow
import BowEffects

public typealias EffectTracedTComponent<Eff: Async & UnsafeRun, WW: Comonad, MM: Monad, State: Monoid, I, V: View> = EffectComponentView<Eff, TracedTPartial<State, WW>, WriterTPartial<MM, State>, I, V>
public typealias EffectTracedComponent<Eff: Async & UnsafeRun, State: Monoid, I, V: View> = EffectTracedTComponent<Eff, ForId, ForId, State, I, V>

public extension EffectTracedTComponent {
//    init<Environment, State: Monoid, Input, WW: Comonad & Applicative, MM: Monad>(
//        environment: Environment,
//        pairing: Pairing<MM, WW>,
//        render: @escaping (State, EffectWriterTHandler<Eff, MM, State, Input>) -> V)
//        where W == TracedTPartial<State, WW>,
//              M == WriterTPartial<MM, State> {
//        self.init(TracedT(WW.pure({ state in
//            UI { send in
//                render(state,
//                       EffectWriterTHandler(send))
//            }
//        })), pairing)
//    }
//
//    init<State: Monoid, Input, WW: Comonad & Applicative, MM: Monad>(
//        pairing: Pairing<MM, WW>,
//        render: @escaping (State, EffectWriterTHandler<Eff, MM, State, Input>) -> V)
//        where W == TracedTPartial<State, WW>,
//              M == WriterTPartial<MM, State> {
//        self.init(environment: () as Any,
//                  pairing: pairing,
//                  render: render)
//    }
}

public extension EffectTracedComponent {
//    init<Environment, State: Monoid, Input>(
//        environment: Environment,
//        render: @escaping (State, EffectWriterHandler<Eff, State, Input>) -> V)
//        where W == TracedPartial<State>,
//              M == WriterPartial<State> {
//        self.init(Traced { state in
//            UI { send in
//                render(state,
//                       EffectWriterHandler(send))
//            }
//        })
//    }
//    
//    init<State: Monoid, Input>(
//        render: @escaping (State, EffectWriterHandler<Eff, State, Input>) -> V)
//        where W == TracedPartial<State>,
//              M == WriterPartial<State> {
//        self.init(environment: () as Any,
//                  render: render)
//    }
}

//public extension EffectTracedTComponent {
//    func tracedT<A, WW: Comonad, MM: Monad>() -> TracedT<A, WW, UI<Eff, M, V>>
//        where W == TracedTPartial<A, WW>,
//              M == WriterTPartial<MM, A> {
//        self.component.wui^
//    }
//}
//
//public extension EffectTracedComponent {
//    func traced<A>() -> Traced<A, UI<Eff, M, V>>
//        where W == TracedPartial<A>,
//              M == WriterPartial<A> {
//        self.component.wui^
//    }
//}
