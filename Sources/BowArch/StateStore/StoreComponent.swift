import SwiftUI
import Bow
import BowEffects
import BowOptics

public struct EffectStoreComponent<Eff: Async & UnsafeRun, S, I, V: View>: View {
    private let componentView: EffectComponentView<Eff, StorePartial<S>, StatePartial<S>, I, V>
    private let initialState: S
    private let dispatcher: EffectStateDispatcher<Eff, S, I>
    private let viewBuilder: (S, @escaping (I) -> Void, EffectStateHandler<Eff, S>) -> V
    
    public init(
        initialState: S,
        dispatcher: EffectStateDispatcher<Eff, S, I>,
        render: @escaping (S, @escaping (I) -> Void) -> V
    ) {
        self.init(
            initialState: initialState,
            dispatcher: dispatcher,
            render: { s, h, _ in render(s, h) })
    }
    
    public init(
        initialState: S,
        dispatcher: EffectStateDispatcher<Eff, S, I>,
        render: @escaping (S, @escaping (I) -> Void, EffectStateHandler<Eff, S>) -> V
    ) {
        self.initialState = initialState
        self.dispatcher = dispatcher
        self.viewBuilder = render
        self.componentView = EffectComponentView(
            EffectComponent(
                Store(initialState) { state in
                    UI { handler in
                        render(state, dispatcher.dispatch(to: handler), handler)
                    }
                },
                Pairing.pairStateStore())
        )
    }
    
    public var body: some View {
        self.componentView
    }
    
    public func lift<S2, I2>(
        initialState: S2,
        lens: Lens<S2, S>,
        prism: Prism<I2, I>
    ) -> EffectStoreComponent<Eff, S2, I2, V> {
        EffectStoreComponent<Eff, S2, I2, V>(
            initialState: initialState,
            dispatcher: self.dispatcher.widen(lens, prism),
            render: { state, handle, handler in
                self.viewBuilder(
                    lens.get(state),
                    prism.reverseGet >>> handle,
                    handler.narrow(lens))
            })
    }
    
    public func using(
        dispatcher: EffectStateDispatcher<Eff, S, I>,
        handler: EffectStateHandler<Eff, S>
    ) -> EffectStoreComponent<Eff, S, I, V> {
        EffectStoreComponent(
            initialState: self.initialState,
            dispatcher: self.dispatcher.combine(dispatcher),
            render: { state, _, _ in
                self.viewBuilder(
                    state,
                    self.dispatcher.combine(dispatcher).dispatch(to: handler),
                    handler)
            })
    }
}

public extension EffectStoreComponent {
    func store() -> Store<S, UI<Eff, StatePartial<S>, V>>{
        self.componentView.component.wui^
    }
}
