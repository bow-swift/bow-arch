import Bow
import BowEffects

public struct EffectReducer<Eff: Async & UnsafeRun, M: Monad, Environment, Input> {
    private let f: (Input, EffectHandler<Eff, M, Environment, Input>) -> Kleisli<Eff, Environment, [Input]>
    
    public init(from f: @escaping (Input, EffectHandler<Eff, M, Environment, Input>) -> Kleisli<Eff, Environment, [Input]>) {
        self.f = f
    }
    
    public func reduce(
        _ input: Input,
        _ handler: EffectHandler<Eff, M, Environment, Input>
    ) -> Kleisli<Eff, Environment, [Input]> {
        self.f(input, handler)
    }
    
    public func sendingTo(
        _ handler: EffectHandler<Eff, M, Environment, Input>,
        environment: Environment
    ) -> (Input) -> Void {
        { input in
            self.f(input, handler)
                .flatMap { inputs in self.reflow(inputs, handler) }^
                .run(environment)
                .runNonBlocking(on: .global(qos: .background))
        }
    }
    
    private func reflow(
        _ inputs: [Input],
        _ handler: EffectHandler<Eff, M, Environment, Input>
    ) -> Kleisli<Eff, Environment, Void> {
        inputs.isEmpty ? Kleisli.pure(())^
            : inputs.flatTraverse { input in self.reduce(input, handler) }^
                .flatMap { inputs in self.reflow(inputs, handler) }^
    }
}

public extension EffectReducer where Environment == Any {
    init(noEnvironment f: @escaping (Input, EffectHandler<Eff, M, Environment, Input>) -> Kind<Eff, [Input]>) {
        self.f = { input, handler in
            Kleisli { _ in f(input, handler) }
        }
    }
    
    init(_ f: @escaping (Input) -> Kind<Eff, [Input]>) {
        self.f = { input, handler in
            Kleisli { _ in f(input) }
        }
    }
    
    init(_ f: @escaping (Input) -> Kind<M, Void>) {
        self.f = { input, handler in
            Kleisli { _ in
                handler.handle(Kleisli { _ in Eff.pure(f(input)) }).as([])
            }
        }
    }
    
    func sendingTo(_ handler: EffectHandler<Eff, M, Environment, Input>) -> (Input) -> Void {
        sendingTo(handler, environment: ())
    }
}
