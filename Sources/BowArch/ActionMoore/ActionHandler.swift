import Bow
import BowEffects

public typealias EffectActionHandler<Eff: Async, Action> = EffectHandler<Eff, ActionPartial<Action>>

public extension EffectActionHandler {
    func focus<AA, A>(_ f: @escaping (AA) -> A)
        -> EffectActionHandler<Eff, AA>
        where M == ActionPartial<A> {
            
        self.lift { action in
            action^.mapAction(f)
        }
    }
}
