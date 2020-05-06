import SwiftUI
import Bow
import BowEffects
import BowOptics

public struct EffectStoreComponent<Eff: Async & UnsafeRun, E, S, I, V: View>: View {
    @ObservedObject var component: EffectComponent<Eff, StorePartial<S>, StatePartial<S>, V>
    private let initialState: S
    private let environment: E
    private let dispatcher: EffectStateDispatcher<Eff, E, S, I>
    private let viewBuilder: (S, @escaping (I) -> Void) -> V
    private let onEffect: (EffectComponent<Eff, StorePartial<S>, StatePartial<S>, V>) -> Kind<Eff, Void>
    
    public init(
        initialState: S,
        environment: E,
        dispatcher: EffectStateDispatcher<Eff, E, S, I>  = .empty(),
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) {
        self.init(initialState: initialState,
            environment: environment,
            dispatcher: dispatcher,
            render: render,
            onEffect: { _ in Eff.lazy() })
    }
    
    private init(
        initialState: S,
        environment: E,
        dispatcher: EffectStateDispatcher<Eff, E, S, I>  = .empty(),
        render: @escaping (S, @escaping (I) -> Void) -> V,
        onEffect: @escaping (EffectComponent<Eff, StorePartial<S>, StatePartial<S>, V>) -> Kind<Eff, Void>
    ) {
        self.initialState = initialState
        self.environment = environment
        self.dispatcher = dispatcher
        self.viewBuilder = render
        self.onEffect = onEffect
        self.component = EffectComponent(
            Store(initialState) { state in
                UI { handler in
                    render(state, dispatcher.dispatch(to: handler, environment: environment))
                }
            },
            Pairing.pairStateStore())
    }
    
    public var body: some View {
        self.component.explore(onEffect: self.onEffect)
    }
    
    public func using<I2>(
        _ handle: @escaping (I2) -> Void,
        transformInput prism: Prism<I2, I>
    ) -> EffectStoreComponent<Eff, E, S, I, V> {
        EffectStoreComponent(
            initialState: self.initialState,
            environment: self.environment,
            dispatcher: self.dispatcher,
            render: { state, _ in
                self.viewBuilder(
                    state,
                    { i in handle(prism.reverseGet(i)) } )
            })
    }
    
    public func onEffect(_ eff: @escaping (EffectComponent<Eff, StorePartial<S>, StatePartial<S>, V>) -> Kind<Eff, Void>) -> EffectStoreComponent<Eff, E, S, I, V> {
        EffectStoreComponent(
            initialState: self.initialState,
            environment: self.environment,
            dispatcher: self.dispatcher,
            render: self.viewBuilder,
            onEffect: { component in
                self.onEffect(component)
                    .followedBy(eff(component))
            })
    }
}

public extension EffectStoreComponent {
    func store() -> Store<S, UI<Eff, StatePartial<S>, V>>{
        self.component.wui^
    }
}

public extension EffectStoreComponent where E == Any {
    init(
        initialState: S,
        dispatcher: EffectStateDispatcher<Eff, Any, S, I> = .empty(),
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) {
        self.init(
            initialState: initialState,
            environment: (),
            dispatcher: dispatcher,
            render: render)
    }
}
