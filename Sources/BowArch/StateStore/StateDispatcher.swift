import Bow
import BowOptics
import BowEffects

public typealias EffectStateTDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, S, Input> = EffectDispatcher<Eff, StateTPartial<M, S>, Environment, Input>
public typealias EffectStateDispatcher<Eff: Async & UnsafeRun, Environment, S, Input> = EffectStateTDispatcher<Eff, ForId, Environment, S, Input>

public extension EffectStateTDispatcher {
    func focus<MM: Monad, GlobalState, LocalState, GlobalEnvironment, GlobalInput>(
        _ getter: Getter<GlobalEnvironment, Environment>,
        _ lens: Lens<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        EffectStateTDispatcher<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput> { input, handler in
            if let newInput = prism.getOptional(input) {
                return self.reduce(newInput, handler.focus(getter, lens)).map { array in
                    array.map(prism.reverseGet)
                    }^.contramap(getter.get)
            } else {
                return Kleisli.pure([])^
            }
        }
    }
    
    func focus<MM: Monad, GlobalState, LocalState, GlobalEnvironment: AutoGetter, GlobalInput>(
        _ keyPath: KeyPath<GlobalEnvironment, Environment>,
        _ lens: Lens<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        focus(GlobalEnvironment.getter(for: keyPath), lens, prism)
    }
    
    func focus<MM: Monad, GlobalState: AutoLens, LocalState, GlobalEnvironment, GlobalInput>(
        _ getter: Getter<GlobalEnvironment, Environment>,
        _ keyPath: WritableKeyPath<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        focus(getter, GlobalState.lens(for: keyPath), prism)
    }
    
    func focus<MM: Monad, GlobalState: AutoLens, LocalState, GlobalEnvironment: AutoGetter, GlobalInput>(
        _ keyPath: KeyPath<GlobalEnvironment, Environment>,
        _ writableKeyPath: WritableKeyPath<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        focus(GlobalEnvironment.getter(for: keyPath), GlobalState.lens(for: writableKeyPath), prism)
    }
    
    func focus<MM: Monad, GlobalState, LocalState, GlobalInput>(
        _ lens: Lens<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, Environment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        focus(.identity, lens, prism)
    }
    
    func focus<MM: Monad, GlobalState: AutoLens, LocalState, GlobalInput>(
        _ keyPath: WritableKeyPath<GlobalState, LocalState>,
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, Environment, GlobalState, GlobalInput>
        where M == StateTPartial<MM, LocalState> {
        focus(.identity, keyPath, prism)
    }
    
    func focus<MM: Monad, State, GlobalEnvironment>(
        _ getter: Getter<GlobalEnvironment, Environment>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, State, Input>
        where M == StateTPartial<MM, State> {
        focus(getter, .identity, .identity)
    }
    
    func focus<MM: Monad, State, GlobalEnvironment: AutoGetter>(
        _ keyPath: KeyPath<GlobalEnvironment, Environment>
    ) -> EffectStateTDispatcher<Eff, MM, GlobalEnvironment, State, Input>
        where M == StateTPartial<MM, State> {
        focus(keyPath, .identity, .identity)
    }
    
    func focus<MM: Monad, GlobalState, LocalState>(
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTDispatcher<Eff, MM, Environment, GlobalState, Input>
        where M == StateTPartial<MM, LocalState> {
        focus(.identity, lens, .identity)
    }
    
    func focus<MM: Monad, GlobalState: AutoLens, LocalState>(
        _ keyPath: WritableKeyPath<GlobalState, LocalState>
    ) -> EffectStateTDispatcher<Eff, MM, Environment, GlobalState, Input>
        where M == StateTPartial<MM, LocalState> {
        focus(.identity, keyPath, .identity)
    }
    
    func focus<MM: Monad, State, GlobalInput>(
        _ prism: Prism<GlobalInput, Input>
    ) -> EffectStateTDispatcher<Eff, MM, Environment, State, GlobalInput>
        where M == StateTPartial<MM, State> {
        focus(.identity, .identity, prism)
    }
}
