import SwiftUI
import Bow
import BowEffects
import BowOptics

public struct EffectStoreComponent<Eff: Async & UnsafeRun, E, S, I, V: View>: View {
    private let componentView: EffectComponentView<Eff, StorePartial<S>, StatePartial<S>, I, V>
    private let initialState: S
    private let environment: E
    private let dispatcher: EffectStateDispatcher<Eff, E, S, I>
    private let viewBuilder: (S, @escaping (I) -> Void, EffectStateHandler<Eff, S>) -> V
    
    public init(
        initialState: S,
        environment: E,
        dispatcher: EffectStateDispatcher<Eff, E, S, I>,
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) {
        self.init(
            initialState: initialState,
            environment: environment,
            dispatcher: dispatcher,
            render: { s, h, _ in render(s, h) })
    }
    
    public init(
        initialState: S,
        environment: E,
        dispatcher: EffectStateDispatcher<Eff, E, S, I>,
        render: @escaping (S, @escaping (I) -> Void, EffectStateHandler<Eff, S>) -> V
    ) {
        self.initialState = initialState
        self.environment = environment
        self.dispatcher = dispatcher
        self.viewBuilder = render
        self.componentView = EffectComponentView(
            EffectComponent(
                Store(initialState) { state in
                    UI { handler in
                        render(state, dispatcher.dispatch(to: handler, environment: environment), handler)
                    }
                },
                Pairing.pairStateStore())
        )
    }
    
    public var body: some View {
        self.componentView
    }
    
    public func lift<E2, S2, I2>(
        initialState: S2,
        environment: E2,
        transformEnvironment f: @escaping (E2) -> E,
        transformState lens: Lens<S2, S>,
        transformInput prism: Prism<I2, I>
    ) -> EffectStoreComponent<Eff, E2, S2, I2, V> {
        EffectStoreComponent<Eff, E2, S2, I2, V>(
            initialState: initialState,
            environment: environment,
            dispatcher: self.dispatcher.widen(
                transformEnvironment: f,
                transformState: lens,
                transformInput: prism),
            render: { state, handle, handler in
                self.viewBuilder(
                    lens.get(state),
                    prism.reverseGet >>> handle,
                    handler.narrow(lens))
            })
    }
    
    public func using(
        dispatcher: EffectStateDispatcher<Eff, E, S, I>,
        handler: EffectStateHandler<Eff, S>
    ) -> EffectStoreComponent<Eff, E, S, I, V> {
        EffectStoreComponent(
            initialState: self.initialState,
            environment: self.environment,
            dispatcher: self.dispatcher.combine(dispatcher),
            render: { state, _, _ in
                self.viewBuilder(
                    state,
                    self.dispatcher.combine(dispatcher).dispatch(to: handler, environment: self.environment),
                    handler)
            })
    }
}

public extension EffectStoreComponent {
    func store() -> Store<S, UI<Eff, StatePartial<S>, V>>{
        self.componentView.component.wui^
    }
}
