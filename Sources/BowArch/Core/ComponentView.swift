import SwiftUI
import Bow
import BowEffects

public struct EffectComponentView<Eff: Async & UnsafeRun, W: Comonad, M: Monad, I, V: View>: View {
    @ObservedObject var component: EffectComponent<Eff, W, M, V>
    
    public init(_ component: EffectComponent<Eff, W, M, V>) {
        self.component = component
    }
    
    public var body: some View {
        component.explore()
    }
    
    public func onEffect(_ eff: @escaping (EffectComponent<Eff, W, M, V>) -> Kind<Eff, Void>) -> EffectComponentView<Eff, W, M, I, V> {
        EffectComponentView(component.onEffect(eff))
    }
    
    public func onEffectAction(_ eff: @escaping (EffectComponent<Eff, W, M, V>, Kind<M, Void>) -> Kind<Eff, Void>) -> EffectComponentView<Eff, W, M, I, V> {
        EffectComponentView(component.onEffectAction(eff))
    }
}
