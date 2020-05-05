import SwiftUI
import Bow
import BowEffects

public final class EffectComponent<Eff: Async & UnsafeRun, W: Comonad, M: Monad, A>: ObservableObject, Equatable {
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
        self.wui.extract().make { base in
            base.flatMap { action in
                write(EffectComponent(self.pairing.select(action, self.wui.duplicate()), self.pairing))
            }
        }
    }
    
    public func lift<MM: Monad, WW: Comonad>(
        _ wf: FunctionK<W, WW>,
        _ mf: FunctionK<M, MM>,
        _ pairing: Pairing<MM, WW>
    ) -> EffectComponent<Eff, WW, MM, A> {
        EffectComponent<Eff, WW, MM, A>(
            wf.invoke(self.wui.map { ui in
                ui.lift(mf.invoke)
            }),
            pairing
        )
    }
    
    public func handling(
        with handler: EffectHandler<Eff, M>
    ) -> EffectComponent<Eff, W, M, A> {
        EffectComponent(self.wui.map { ui in
            ui.handling(with: handler)
        }, self.pairing)
    }
    
    public func onEffect(_ eff: @escaping (EffectComponent<Eff, W, M, A>) -> Kind<Eff, Void>) -> EffectComponent<Eff, W, M, A> {
        EffectComponent(self.wui.coflatMap { wa in
            self.effect { wa in eff(EffectComponent(wa, self.pairing)) }
        }, self.pairing)
    }
    
    public func onEffectAction(_ eff: @escaping (EffectComponent<Eff, W, M, A>, Kind<M, Void>) -> Kind<Eff, Void>) -> EffectComponent<Eff, W, M, A> {
        EffectComponent(self.wui.coflatMap { wa in
            self.effectAction { wa, action in
                eff(EffectComponent(wa, self.pairing), action)
            }
        }, self.pairing)
    }
    
    private func effect(_ eff: @escaping (Kind<W, UI<Eff, M, A>>) -> Kind<Eff, Void>) -> UI<Eff, M, A> {
        UI<Eff, M, A> { handler in
            self.wui.extract().make { base in
                let action = Kind<Eff, Kind<M, Void>>.var()
                
                let event = binding(
                    action <- base,
                    |<-eff(self.pairing.select(action.get, self.wui.duplicate())),
                    yield: action.get)
                
                return handler.handle(event)
            } 
        }
    }
    
    private func effectAction(_ eff: @escaping (Kind<W, UI<Eff, M, A>>, Kind<M, Void>) -> Kind<Eff, Void>) -> UI<Eff, M, A> {
        UI<Eff, M, A> { handler in
            self.wui.extract().make { base in
                let action = Kind<Eff, Kind<M, Void>>.var()
                
                let event = binding(
                    action <- base,
                    |<-eff(self.pairing.select(action.get, self.wui.duplicate()), action.get),
                    yield: action.get)
                
                return handler.handle(event)
            }
        }
    }
}

public func ==<Eff: Monad, W: Comonad, M: Monad, A>(
    lhs: EffectComponent<Eff, W, M, A>,
    rhs: EffectComponent<Eff, W, M, A>
) -> Bool {
    lhs === rhs
}

public extension EffectComponent {
    func store<S>() -> Store<S, UI<Eff, M, A>>
    where W == StorePartial<S>,
          M == StatePartial<S> {
        self.wui^
    }
}
