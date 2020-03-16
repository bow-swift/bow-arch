import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, Environment, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Environment, Input>
public typealias EffectStateHandler<Eff: Async, Environment, State, Input> = EffectStateTHandler<Eff, ForId, Environment, State, Input>

public extension EffectStateTHandler {
    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment, LocalInput>(
        _ getter: Getter<Environment, LocalEnvironment>,
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        EffectStateTHandler(
            { eff in eff.map { state in state^.focus(lens) }^ } >>> self.handle
        ).map(getter.get)
    }
    
    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment, LocalInput>(
        _ f: @escaping (Environment) -> LocalEnvironment,
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus(Getter(get: f), lens)
    }
    
    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment, LocalInput>(
        _ keyPath: KeyPath<Environment, LocalEnvironment>,
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus({ x in x[keyPath: keyPath] }, lens)
    }
    
    func focus<MM: Monad, LocalState, GlobalState: AutoLens, LocalEnvironment, LocalInput>(
        _ getter: Getter<Environment, LocalEnvironment>,
        _ keyPath: WritableKeyPath<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus(getter, GlobalState.lens(for: keyPath))
    }

    func focus<MM: Monad, LocalState, GlobalState: AutoLens, LocalEnvironment, LocalInput>(
        _ keyPath: KeyPath<Environment, LocalEnvironment>,
        _ writableKeyPath: WritableKeyPath<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus(keyPath, GlobalState.lens(for: writableKeyPath))
    }
    
    func focus<MM: Monad, LocalState, GlobalState, LocalInput>(
        _ lens: Lens<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, Environment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus(.identity, lens)
    }
    
    func focus<MM: Monad, LocalState, GlobalState: AutoLens, LocalInput>(
        _ keyPath: WritableKeyPath<GlobalState, LocalState>
    ) -> EffectStateTHandler<Eff, MM, Environment, LocalState, LocalInput>
        where M == StateTPartial<MM, GlobalState> {
        focus(.identity, keyPath)
    }
}
