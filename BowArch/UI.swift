import Bow
import BowEffects

public final class UI<Eff: Async, M: Monad, A> {
    let makeView: (@escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) -> A
    
    public init(_ makeView: @escaping (@escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Void>) -> A) {
        self.makeView = makeView
    }
}
