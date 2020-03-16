import SwiftUI
import Bow
import BowEffects

public final class EffectComponent<Eff: Async, W: Comonad, M: Monad, A>: ObservableObject {
    @Published var wui: Kind<W, UI<Eff, M, A>>
    let pairing: Pairing<M, W>
    
    public init(_ component: Kind<W, UI<Eff, M, A>>, _ pairing: Pairing<M, W>) {
        self.wui = component
        self.pairing = pairing
    }
}
