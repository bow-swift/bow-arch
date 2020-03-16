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
}
