import Bow
import BowEffects

public struct EffectDispatcher<Eff: Async & UnsafeRun, M: Monad, Environment, Input> {
    private let f: (Input, EffectHandler<Eff, M, Input>) -> Kleisli<Eff, Environment, [Input]>
    
    public init(from f: @escaping (Input, EffectHandler<Eff, M, Input>) -> Kleisli<Eff, Environment, [Input]>) {
        self.f = f
    }
    
    public func dispatch(
        _ input: Input,
        _ handler: EffectHandler<Eff, M, Input>
    ) -> Kleisli<Eff, Environment, [Input]> {
        self.f(input, handler)
    }
    
    public func sendingTo(
        _ handler: EffectHandler<Eff, M, Input>,
        environment: Environment
    ) -> (Input) -> Void {
        { input in
            self.dispatch(input, handler)
                .flatMap { inputs in self.reflow(inputs, handler) }^
                .run(environment)
                .runNonBlocking(on: .global(qos: .background))
        }
    }
    
    private func reflow(
        _ inputs: [Input],
        _ handler: EffectHandler<Eff, M, Input>
    ) -> Kleisli<Eff, Environment, Void> {
        inputs.isEmpty ? Kleisli.pure(())^
            : inputs.flatTraverse { input in self.dispatch(input, handler) }^
                .flatMap { inputs in self.reflow(inputs, handler) }^
    }
}

public extension EffectDispatcher where Environment == Any {    
//    init(_ f: @escaping (Input) -> Kind<Eff, [Input]>) {
//        self.f = { input, handler in
//            Kleisli { _ in f(input) }
//        }
//    }
//
//    init(_ f: @escaping (Input) -> Kind<M, Void>) {
//        self.f = { input, handler in
//            Kleisli { _ in
//                handler.handle(Kleisli { _ in Eff.pure(f(input)) }).as([])
//            }
//        }
//    }
    
    func sendingTo(_ handler: EffectHandler<Eff, M, Input>) -> (Input) -> Void {
        sendingTo(handler, environment: ())
    }
}

// MARK: Instance of Semigroup for Dispatcher

extension EffectDispatcher: Semigroup {
    public func combine(_ other: EffectDispatcher<Eff, M, Environment, Input>) -> EffectDispatcher<Eff, M, Environment, Input> {
        EffectDispatcher { input, handler in
            let fst = Kleisli<Eff, Environment, [Input]>.var()
            let snd = Kleisli<Eff, Environment, [Input]>.var()
            
            return binding(
                fst <- self.dispatch(input, handler),
                snd <- other.dispatch(input, handler),
                yield: fst.get + snd.get)^
        }
    }
}

// MARK: Instance of Monoid for Dispatcher

extension EffectDispatcher: Monoid {
    public static func empty() -> EffectDispatcher<Eff, M, Environment, Input> {
        EffectDispatcher { _, _ in Kleisli.pure([])^ }
    }
}
