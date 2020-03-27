import Bow
import BowEffects
import BowOptics

public typealias EffectStateTHandler<Eff: Async, M: Monad, Environment, State, Input> = EffectHandler<Eff, StateTPartial<M, State>, Environment, Input>
public typealias EffectStateHandler<Eff: Async, Environment, State, Input> = EffectStateTHandler<Eff, ForId, Environment, State, Input>

public extension EffectStateTHandler {
    func focus<MM: Monad, S, SS>(
        _ lens: Lens<SS, S>
    ) -> EffectStateTHandler<Eff, MM, Environment, S, Input>
        where M == StateTPartial<MM, SS> {
        EffectStateTHandler(
            { eff in
                eff.map { state in
                    state^.focus(lens)
                }^
            } >>> self.handle
        )
    }
}

//public extension EffectStateTHandler {
//    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment>(
//        _ getter: Getter<Environment, LocalEnvironment>,
//        _ lens: Lens<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        EffectStateTHandler(
//            { eff in eff.map { state in state^.focus(lens) }^ } >>> self.handle
//        ).map(getter.get)
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment>(
//        _ f: @escaping (Environment) -> LocalEnvironment,
//        _ lens: Lens<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus(Getter(get: f), lens)
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState, LocalEnvironment>(
//        _ keyPath: KeyPath<Environment, LocalEnvironment>,
//        _ lens: Lens<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus({ x in x[keyPath: keyPath] }, lens)
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState: AutoLens, LocalEnvironment>(
//        _ getter: Getter<Environment, LocalEnvironment>,
//        _ keyPath: WritableKeyPath<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus(getter, GlobalState.lens(for: keyPath))
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState: AutoLens, LocalEnvironment>(
//        _ keyPath: KeyPath<Environment, LocalEnvironment>,
//        _ writableKeyPath: WritableKeyPath<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, LocalEnvironment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus(keyPath, GlobalState.lens(for: writableKeyPath))
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState>(
//        _ lens: Lens<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, Environment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus(.identity, lens)
//    }
//
//    func focus<MM: Monad, LocalState, GlobalState: AutoLens>(
//        _ keyPath: WritableKeyPath<GlobalState, LocalState>
//    ) -> EffectStateTHandler<Eff, MM, Environment, LocalState, Input>
//        where M == StateTPartial<MM, GlobalState> {
//        focus(.identity, keyPath)
//    }
//}
