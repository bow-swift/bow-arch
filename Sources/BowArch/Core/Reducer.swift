import Bow
import BowOptics

public struct Reducer<State, Input> {
    let f: (State, Input) -> State
    
    public init(_ f: @escaping (State, Input) -> State) {
        self.f = f
    }
    
    public func run(_ state: State, _ input: Input) -> State {
        f(state, input)
    }
    
    public func focus<ParentState, ParentInput>(
        _ lens: Lens<ParentState, State>,
        _ prism: Prism<ParentInput, Input>
    ) -> Reducer<ParentState, ParentInput> {
        Reducer<ParentState, ParentInput> { state, input in
            guard let childInput = prism.getOptional(input) else {
                return state
            }
            let newState = self.run(lens.get(state), childInput)
            return lens.set(state, newState)
        }
    }
    
    public func focus<ParentState: AutoLens, ParentInput: AutoPrism>(
        _ keyPath: WritableKeyPath<ParentState, State>,
        _ embed: @escaping (Input) -> ParentInput
    ) -> Reducer<ParentState, ParentInput> {
        focus(ParentState.lens(for: keyPath), ParentInput.prism(for: embed))
    }
    
    public func focus<ParentState>(
        _ lens: Lens<ParentState, State>
    ) -> Reducer<ParentState, Input> {
        focus(lens, .identity)
    }
    
    public func focus<ParentState: AutoLens>(
        _ keyPath: WritableKeyPath<ParentState, State>
    ) -> Reducer<ParentState, Input> {
        focus(ParentState.lens(for: keyPath), .identity)
    }
    
    public func focus<ParentInput>(
        _ prism: Prism<ParentInput, Input>
    ) -> Reducer<State, ParentInput> {
        focus(.identity, prism)
    }
    
    public func focus<ParentInput: AutoPrism>(
        _ embed: @escaping (Input) -> ParentInput
    ) -> Reducer<State, ParentInput> {
        focus(.identity, ParentInput.prism(for: embed))
    }
}
