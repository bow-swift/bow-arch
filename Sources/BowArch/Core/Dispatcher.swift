import Bow
import BowEffects

public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, I> {
    private let f: (I) -> [Kind<Eff, Kind<M, Void>>]
    
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
    
    public func scope<I2, MM: Monad>(
        _ f: @escaping (I2) -> I?,
        _ g: @escaping (Kind<M, Void>) -> Kind<MM, Void>
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

//public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, Input> {
//    private let f: (Input, EffectHandler<Eff, M>) -> Kleisli<Eff, Environment, Void>
//
//    public init(from f: @escaping (Input, EffectHandler<Eff, M>) -> Kleisli<Eff, Environment, Void>) {
//        self.f = f
//    }
//
//    public func dispatch(
//        _ input: Input,
//        _ handler: EffectHandler<Eff, M>
//    ) -> Kleisli<Eff, Environment, Void> {
//        self.f(input, handler)
//    }
//
//    public func sendingTo(
//        _ handler: EffectHandler<Eff, M>,
//        environment: Environment
//    ) -> (Input) -> Void {
//        { input in
//            self.dispatch(input, handler)
//                .run(environment)
//                .runNonBlocking(on: .global(qos: .background))
//        }
//    }
//
//    public func lift<MM: Monad, E2, I2>(
//        _ transformEnvironment: @escaping (E2) -> Environment,
//        _ transformAction: @escaping (Kind<M, Void>) -> Kind<MM, Void>,
//        _ transformInput: @escaping (I2) -> Input?
//    ) -> EffectDispatcher<Eff, MM, E2, I2> {
//        EffectDispatcher<Eff, MM, E2, I2> { input, handler in
//            if let newInput = transformInput(input) {
//                let newHandler = handler.lift(transformAction)
//                return self.dispatch(newInput, newHandler).contramap(transformEnvironment)
//            } else {
//                return handler.noOp()
//            }
//        }
//    }
//}
//
//public extension EffectDispatcher where Environment == Any {
//    func sendingTo(_ handler: EffectHandler<Eff, M>) -> (Input) -> Void {
//        sendingTo(handler, environment: ())
//    }
//}
//
//// MARK: Instance of Semigroup for Dispatcher
//
//extension EffectDispatcher: Semigroup {
//    public func combine(_ other: EffectDispatcher<Eff, M, Environment, Input>) -> EffectDispatcher<Eff, M, Environment, Input> {
//        EffectDispatcher { input, handler in
//            self.dispatch(input, handler)
//                .followedBy(other.dispatch(input, handler))^
//        }
//    }
//}
//
//// MARK: Instance of Monoid for Dispatcher
//
//extension EffectDispatcher: Monoid {
//    public static func empty() -> EffectDispatcher<Eff, M, Environment, Input> {
//        EffectDispatcher { _, _ in Kleisli.pure(())^ }
//    }
//}
