import SwiftUI
import Bow
import BowEffects

public final class EffectComponent<Eff: Async, W: Comonad, M: Monad, A>: ObservableObject, Equatable {
    @Published var wui: Kind<W, UI<Eff, M, A>>
    let pairing: Pairing<M, W>
    
    public init(_ component: Kind<W, UI<Eff, M, A>>, _ pairing: Pairing<M, W>) {
        self.wui = component
        self.pairing = pairing
    }
    
    public func explore() -> A {
        self.explore { c in
            Eff.later(.main) { self.wui = c.wui }
        }
    }
    
    public func explore(_ write: @escaping (EffectComponent<Eff, W, M, A>) -> Kind<Eff, Void>) -> A {
        self.wui.extract().makeView({ base in
            base.flatMap { action in
                write(EffectComponent(self.pairing.select(action, self.wui.duplicate()), self.pairing))
            }
        })
    }
}

public func ==<Eff: Monad, W: Comonad, M: Monad, A>(
    lhs: EffectComponent<Eff, W, M, A>,
    rhs: EffectComponent<Eff, W, M, A>
) -> Bool {
    lhs === rhs
}
