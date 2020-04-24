import Bow
import BowEffects

public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, Input> {
    private let f: (Input, EffectHandler<Eff, M>) -> Kleisli<Eff, Environment, Void>
    
    public init(from f: @escaping (Input, EffectHandler<Eff, M>) -> Kleisli<Eff, Environment, Void>) {
        self.f = f
    }
    
    public func dispatch(
        _ input: Input,
        _ handler: EffectHandler<Eff, M>
    ) -> Kleisli<Eff, Environment, Void> {
        self.f(input, handler)
    }
    
    public func sendingTo(
        _ handler: EffectHandler<Eff, M>,
        environment: Environment
    ) -> (Input) -> Void {
        { input in
            self.dispatch(input, handler)
                .run(environment)
                .runNonBlocking(on: .global(qos: .background))
        }
    }
    
    public func lift<MM: Monad, E2, I2>(
        _ transformEnvironment: @escaping (E2) -> Environment,
        _ transformAction: @escaping (Kind<M, Void>) -> Kind<MM, Void>,
        _ transformInput: @escaping (I2) -> Input?
    ) -> EffectDispatcher<Eff, MM, E2, I2> {
        EffectDispatcher<Eff, MM, E2, I2> { input, handler in
            if let newInput = transformInput(input) {
                let newHandler = handler.lift(transformAction)
                return self.dispatch(newInput, newHandler).contramap(transformEnvironment)
            } else {
                return handler.noOp()
            }
        }
    }
}

public extension EffectDispatcher where Environment == Any {    
    func sendingTo(_ handler: EffectHandler<Eff, M>) -> (Input) -> Void {
        sendingTo(handler, environment: ())
    }
}

// MARK: Instance of Semigroup for Dispatcher

extension EffectDispatcher: Semigroup {
    public func combine(_ other: EffectDispatcher<Eff, M, Environment, Input>) -> EffectDispatcher<Eff, M, Environment, Input> {
        EffectDispatcher { input, handler in
            self.dispatch(input, handler)
                .followedBy(other.dispatch(input, handler))^
        }
    }
}

// MARK: Instance of Monoid for Dispatcher

extension EffectDispatcher: Monoid {
    public static func empty() -> EffectDispatcher<Eff, M, Environment, Input> {
        EffectDispatcher { _, _ in Kleisli.pure(())^ }
    }
}
