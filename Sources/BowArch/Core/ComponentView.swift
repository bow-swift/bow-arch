import SwiftUI
import Bow
import BowEffects

public struct EffectComponentView<Eff: Async, W: Comonad, M: Monad, V: View>: View {
    @ObservedObject var component: EffectComponent<Eff, W, M, V>
    
    public init(_ component: EffectComponent<Eff, W, M, V>) {
        self.component = component
    }
    
    public var body: some View {
        component.explore()
    }
    
    public func onEffect(_ eff: @escaping (EffectComponent<Eff, W, M, V>) -> Kind<Eff, Void>) -> EffectComponentView<Eff, W, M, V> {
        EffectComponentView(self.component.onEffect(eff))
    }
    
    public func onEffectAction(_ eff: @escaping (EffectComponent<Eff, W, M, V>, Kind<M, Void>) -> Kind<Eff, Void>) -> EffectComponentView<Eff, W, M, V> {
        EffectComponentView(self.component.onEffectAction(eff))
    }
}

//public extension EffectComponentView {
//    // MARK: Initializers for Store-State
//    
//    init<A>(_ wa: Kind<W, UI<Eff, M, V>>)
//        where W == StorePartial<A>,
//              M == StatePartial<A> {
//        self.init(EffectComponent(wa, Pairing.pairStateStore()))
//    }
//    
//    init<A, WW: Comonad, MM: Monad>(
//        _ wa: Kind<W, UI<Eff, M, V>>,
//        _ pairing: Pairing<MM, WW>)
//        where W == StoreTPartial<A, WW>,
//              M == StateTPartial<MM, A> {
//        self.init(EffectComponent(wa, Pairing.pairStateTStoreT(pairing)))
//    }
//    
//    // MARK: Initializers for Traced-Writer
//    
//    init<A: Monoid>(_ wa: Kind<W, UI<Eff, M, V>>)
//        where W == TracedPartial<A>,
//              M == WriterPartial<A> {
//        self.init(EffectComponent(wa, Pairing.pairWriterTraced()))
//    }
//    
//    init<A: Monoid, WW: Comonad, MM: Monad>(
//        _ wa: Kind<W, UI<Eff, M, V>>,
//        _ pairing: Pairing<MM, WW>)
//        where W == TracedTPartial<A, WW>,
//              M == WriterTPartial<MM, A> {
//        self.init(EffectComponent(wa, Pairing.pairWriterTTracedT(pairing)))
//    }
//    
//    // MARK: Initializers for Moore-Action
//    
//    init<A>(_ wa: Kind<W, UI<Eff, M, V>>)
//        where W == MoorePartial<A>,
//        M == ActionPartial<A> {
//        self.init(EffectComponent(wa, Pairing.pairActionMoore()))
//    }
//}
