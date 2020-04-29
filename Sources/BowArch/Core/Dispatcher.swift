import Bow
import BowEffects

public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, E, I> {
    private let f: (I) -> [Kleisli<Eff, E, Kind<M, Void>>]
    
    public init(_ f: @escaping (I) -> [Kleisli<Eff, E, Kind<M, Void>>]) {
        self.f = f
    }
    
    public func on(_ input: I) -> [Kleisli<Eff, E, Kind<M, Void>>] {
        f(input)
    }
    
    public func dispatch(to handler: EffectHandler<Eff, M>, environment: E) -> (I) -> Void {
        { input in
            self.on(input).traverse { eff in
                handler.handle(eff^.run(environment))
            }.void()
            .runNonBlocking(on: .global(qos: .background))
        }
    }
    
    public func widen<I2, MM: Monad, E2>(
        _ h: @escaping (E2) -> E,
        _ g: @escaping (Kind<M, Void>) -> Kind<MM, Void>,
        _ f: @escaping (I2) -> I?
    ) -> EffectDispatcher<Eff, MM, E2, I2> {
        self.contramap(f).lift(g).lift(h)
    }
    
    public func contramap<I2>(_ f: @escaping (I2) -> I?) -> EffectDispatcher<Eff, M, E, I2> {
        EffectDispatcher<Eff, M, E, I2> { i in
            if let input = f(i) {
                return self.on(input)
            } else {
                return []
            }
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<M, Void>) -> Kind<MM, Void>) -> EffectDispatcher<Eff, MM, E, I> {
        EffectDispatcher<Eff, MM, E, I> { input in
            self.on(input).map { kleisli in
                kleisli.map(f)^
            }
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kleisli<Eff, E, Kind<M, Void>>) -> Kleisli<Eff, E, Kind<MM, Void>>) -> EffectDispatcher<Eff, MM, E, I> {
        EffectDispatcher<Eff, MM, E, I> { input in
            self.on(input).map(f)
        }
    }
    
    public func lift<E2>(_ f: @escaping (E2) -> E) -> EffectDispatcher<Eff, M, E2, I> {
        EffectDispatcher<Eff, M, E2, I> { input in
            self.on(input).map { kleisli in
                kleisli.contramap(f)
            }
        }
    }
}

extension EffectDispatcher: Semigroup {
    public func combine(_ other: EffectDispatcher<Eff, M, E, I>) -> EffectDispatcher<Eff, M, E, I> {
        EffectDispatcher { input in
            self.on(input) + other.on(input)
        }
    }
}

extension EffectDispatcher: Monoid {
    public static func empty() -> EffectDispatcher<Eff, M, E, I> {
        EffectDispatcher { _ in [] }
    }
}
