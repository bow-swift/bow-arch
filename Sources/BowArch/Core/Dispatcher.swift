import Bow
import BowEffects

public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, I> {
    private let f: (I) -> [Kind<Eff, Kind<M, Void>>]
    
    public static func pure(_ f: @escaping (I) -> Kind<M, Void>) -> EffectDispatcher<Eff, M, I> {
        .effectful(f >>> Eff.pure)
    }
    
    public static func effectful(_ f: @escaping (I) -> Kind<Eff, Kind<M, Void>>) -> EffectDispatcher<Eff, M, I> {
        .workflow { input in [f(input)] }
    }
    
    public static func workflow(_ f: @escaping (I) -> [Kind<Eff, Kind<M, Void>>]) -> EffectDispatcher<Eff, M, I> {
        EffectDispatcher(f)
    }
    
    public init(_ f: @escaping (I) -> [Kind<Eff, Kind<M, Void>>]) {
        self.f = f
    }
    
    public func on(_ input: I) -> [Kind<Eff, Kind<M, Void>>] {
        f(input)
    }
    
    public func dispatch(to handler: EffectHandler<Eff, M>) -> (I) -> Void {
        { input in
            self.on(input).traverse { eff in
                handler.handle(eff)
            }.void()
            .runNonBlocking(on: .global(qos: .background))
        }
    }
    
    public func widen<I2, MM: Monad>(
        _ g: @escaping (Kind<M, Void>) -> Kind<MM, Void>,
        _ f: @escaping (I2) -> I?
    ) -> EffectDispatcher<Eff, MM, I2> {
        self.contramap(f).lift(g)
    }
    
    public func contramap<I2>(_ f: @escaping (I2) -> I?) -> EffectDispatcher<Eff, M, I2> {
        EffectDispatcher<Eff, M, I2> { i in
            if let input = f(i) {
                return self.on(input)
            } else {
                return []
            }
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<M, Void>) -> Kind<MM, Void>) -> EffectDispatcher<Eff, MM, I> {
        EffectDispatcher<Eff, MM, I> { input in
            self.on(input).map { eff in
                eff.map(f)
            }
        }
    }
    
    public func lift<MM: Monad>(_ f: @escaping (Kind<Eff, Kind<M, Void>>) -> Kind<Eff, Kind<MM, Void>>) -> EffectDispatcher<Eff, MM, I> {
        EffectDispatcher<Eff, MM, I> { input in
            self.on(input).map(f)
        }
    }
}

extension EffectDispatcher: Semigroup {
    public func combine(_ other: EffectDispatcher<Eff, M, I>) -> EffectDispatcher<Eff, M, I> {
        EffectDispatcher { input in
            self.on(input) + other.on(input)
        }
    }
}

extension EffectDispatcher: Monoid {
    public static func empty() -> EffectDispatcher<Eff, M, I> {
        EffectDispatcher { _ in [] }
    }
}
