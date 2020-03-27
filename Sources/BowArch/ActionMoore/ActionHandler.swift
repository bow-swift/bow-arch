import Bow
import BowEffects

public typealias EffectActionHandler<Eff: Async, Environment, Action, Input> = EffectHandler<Eff, ActionPartial<Action>, Environment, Input>

public extension EffectActionHandler {
    func focus<AA, A>(_ f: @escaping (AA) -> A)
        -> EffectActionHandler<Eff, Environment, AA, Input>
        where M == ActionPartial<A> {
            
        EffectActionHandler(
            { eff in
                eff.map { action in
                    action^.mapAction(f)
                }^
            } >>> self.handle
        )
    }
}
