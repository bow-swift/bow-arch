// nef:begin:header
/*
 layout: docs
 title: Dispatcher
 */
// nef:end
// nef:begin:hidden
import BowArch
import Bow
import BowEffects
import BowOptics
// nef:end
/*:
 # Dispatcher
 
 Inputs in the user interface need to be transformed into actions that trigger state changes. That is the responsibility of the Dispatcher: take inputs and transform them into actions that modify the state.
 
 Dispatchers have three parameters:
 
 - **Environment**: represents the dependencies we need to perform the actions for the received inputs.
 - **State**: represents the type of the state the dispatcher can modify when an input is received.
 - **Input**: represents the type of inputs the dispatcher is able to handle.
 
 Internally, a dispatcher is a function from the input type, to an array of side-effectful actions that depend on an environment and mutate a state; that is:
 
 `(I) -> [EnvIO<E, Error, State<S, Void>>]`
 
 where:
 
 - `I` is the input type.
 - `EnvIO` is a type to model side-effectful operations that depend on an environment.
 - `E` is the environment type.
 - `State` is a monad that models state-based computations.
 - `S` is the state type.
 
 Each action in the array will trigger a UI refresh; this is because some inputs may trigger a UI update, then do a long-running task, and finally trigger a new UI update to show the final result.
 
 Nonetheless, we can create dispatchers for actions that involve single UI updates, or even ones that are side-effect free, with the following methods:
 
 - `pure`: lets us create side-effect free dispatchers that have no dependencies and state modification is pure.
 - `effectful`: lets us create single action dispatchers that may have dependencies and require side effects to modify the state.
 - `workflow`: lets us create side-effectful dispatchers that may have dependencies and perform multiple UI updates.
 
 ## Examples
 
 ### Pure Dispatcher
 
 Incrementing or decrementing the count of a stepper is a pure state modification, so we can create a dispatcher like:
 */
enum StepperInput {
    case tapDecrement
    case tapIncrement
}

typealias StepperDispatcher = StateDispatcher<Any, Int, StepperInput>

let stepperDispatcher = StepperDispatcher.pure { input in
    switch input {
    case .tapDecrement:
        return .modify { count in count - 1 }^
    case .tapIncrement:
        return .modify { count in count + 1 }^
    }
}
/*:
 ## Effectful Dispatcher
 
 Rolling a die is a side-effectful action, as it includes randomness. We can capture randomness in a dependency:
 */
protocol Randomness {
    func getInt<E>(in range: ClosedRange<Int>) -> EnvIO<E, Error, Int>
}
/*:
 Then, we can create our dispatcher as:
 */
enum DieInput {
    case roll
}

struct Die {
    let number: Int
}

typealias DieDispatcher = StateDispatcher<Randomness, Die, DieInput>

let dieDispatcher = DieDispatcher.effectful { input in
    switch input {
    case .roll:
        return EnvIO.accessM { random in random.getInt(in: 1 ... 6) }
            .map { n in
                .set(Die(number: n))^
            }^
    }
}
/*:
 ### Workflow Dispatcher
 
 Finally, we can create a dispatcher that triggers multiple UI updates. For instance, we may show a loading indicator, fetch data from the network, and then show it in the UI.
 */
// Dependencies
protocol Network {
    func load<E>() -> EnvIO<E, Error, Data>
}

// State
enum ScreenState {
    case loading
    case loaded(Data)
}

// Input
enum ScreenInput {
    case fetchData
}

// Dispatcher
typealias ScreenDispatcher = StateDispatcher<Network, ScreenState, ScreenInput>

func showLoading() -> EnvIO<Network, Error, State<ScreenState, Void>> {
    EnvIO.pure(.set(.loading)^)^
}

func showLoadedData() -> EnvIO<Network, Error, State<ScreenState, Void>> {
    let network = EnvIO<Network, Error, Network>.var()
    let data = EnvIO<Network, Error, Data>.var()
    
    return binding(
        continueOn(.global(qos: .background)),
        network <- .ask(),
        data <- network.get.load(),
        yield: .set(.loaded(data.get))^
    )^
}

let screenDispatcher = ScreenDispatcher.workflow { input in
    switch input {
    case .fetchData:
        return [
            showLoading(),
            showLoadedData()
        ]
    }
}
/*:
 ## Combining Dispatchers
 
 As long as two dispatchers share the same type parameters, they can be combined, as they conform to `Semigroup`.
 
 If they don't have the same type parameters, they can be transformed using the `widen` method, which needs the following:
 
 - A function to extract the environment from a parent environment.
 - A lens to extract the state from a parent state.
 - A prism to extract the input from a parent input.
 
 For instance, consider the `screenDispatcher` above needs to be combined with a parent dispatcher that works on more general environment, state and input:
 */
// nef:begin:hidden
protocol Database {}
struct OtherState {}
enum OtherInput {}
// nef:end
struct Dependencies {
    let network: Network
    let database: Database
}

struct ParentState {
    let screen: ScreenState
    let other: OtherState
}

enum ParentInput {
    case screen(ScreenInput)
    case other(OtherInput)
}

typealias ParentDispatcher = StateDispatcher<Dependencies, ParentState, ParentInput>
/*:
 First, we need to create a lens and a prism to focus on the state and input of our child dispatcher:
 */
let screenLens = Lens<ParentState, ScreenState>(
    get: { parent in parent.screen },
    set: { parent, newScreen in ParentState(screen: newScreen, other: parent.other) }
)

extension ParentInput: AutoPrism {}
let screenPrism = ParentInput.prism(for: ParentInput.screen)
/*:
 Then, we can widen our `screenDispatcher` to have the same type parameters as the parent:
 */
let widenScreenDispatcher: ParentDispatcher = screenDispatcher.widen(
    transformEnvironment: { dependencies in dependencies.network },
    transformState: screenLens,
    transformInput: screenPrism
)
/*:
 And finally, we can combine both dispatchers:
 */
// nef:begin:hidden
let parentDispatcher = ParentDispatcher.workflow { _ in [] }
// nef:end
let appDispatcher = parentDispatcher.combine(widenScreenDispatcher)
/*:
 This lets us write very focused dispatchers that only receive what they need to perform their job, separate our concerns properly, and then have powerful ways to compose them into a single dispatcher that manages the logic of our application.
 */
