// nef:begin:header
/*
 layout: docs
 title: Comonadic UIs
 */
// nef:end
// nef:begin:hidden
import SwiftUI
import Bow
import BowEffects

struct State<S, A> {
    let run: (S) -> (S, A)
}
// nef:end
/*:
 # Comonadic UIs
 
 Now that we have presented Monads and Comonads, and their Pairing relationship, let's see how this plays a role on building user interfaces. We will do it following our intuition in an example.
 
 ## A SwiftUI View
 
 Let's build a SwiftUI View according to how it is recommended in the framework documentation. We can create a view to show a stepper:
 */
// nef:begin:hidden
class Snippet1 {
// nef:end
struct StepperView: View {
    @SwiftUI.State var count: Int
    
    var body: some View {
        HStack {
            Button("-") { self.count -= 1 }
            Text("\(count)")
            Button("+") { self.count += 1 }
        }
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 A view in SwiftUI must implement the `View` protocol, imposing the implementation of a `body` property that describes its internal structure. It provides built-in widgets, like `HStack`, `Button` and `Text` to render the view. SwiftUI also provides the `@State` property wrapper, which is used to observe state changes and trigger redraws of the view.
 
 We can observe some problems with this approach. First of all, business logic is entangled in presentation logic. We could extract it, but still the view will have to know which logic needs to be invoked. Second, the view is based on mutable state, which could potentially result in difficulties to reason about the code.
 
 ## View as a function of immutable state
 
 Let's try to rewrite the previous view in a different way:
 */
enum StepperInput {
    case tapDecrement
    case tapIncrement
}

struct StepperView: View {
    let count: Int
    let handle: (StepperInput) -> Void
    
    var body: some View {
        HStack {
            Button("-") { self.handle(.tapDecrement) }
            Text("\(count)")
            Button("+") { self.handle(.tapIncrement) }
        }
    }
}
/*:
 With this version we have performed some small changes that may have a profound implication:
 
 - View is a function of immutable state. We have lost the ability to trigger changes on it, but we will retrieve it later.
 - Logic is stripped out of the view; instead, the view communicates events through a function.
 
 With this, we have achieved that our View is now a function:
 
 `(Int, (StepperInput) -> Void) -> StepperView`
 
 If we use `S` for a generic state, `I` for a generic input, and `V` for a generic views, we could be modelling all of our views as a function:
 
 `view :: (S, (I) -> Void) -> V`
 
 ## Handling inputs
 
 Let's focus on the input handling function. Its signature is `(I) -> Void`. The only way a function with that signature could be implemented as a pure function is to have an empty body; therefore, we must assume this function is performing side effects.
 
 On the other hand, handling the inputs produced by user interactions on the view should trigger state mutations. In order to perform those state mutations, we may also need to perform side effects. State mutations can be modeled using the State Monad; in particular, if our mutations are not producing any other values, we can model such mutations using `State<S, Void>`, given our state has type `S`. As for side effects, we can model them using `IO`.
 
 Therefore, we could split the original function `(I) -> Void` as:
 
 - `(I) -> IO<Error, State<S, Void>>`
 - `(IO<Error, State<S, Void>>) -> IO<Error, Void>`
 - `(IO<Error, Void>) -> Void`
 
 As you can see, the output type of a function matches the input of the following; thus, if we compose them, we can have our initial `(I) -> Void`.
 
 The first function `(I) -> IO<Error, State<S, Void>>` is a function that must be provided to interpret how to map inputs to state mutations. It describes the application logic, and therefore must be provided for each specific case. In Bow Arch, it is modeled as a `StateDispatcher`.
 
 The second function has a signature `(IO<Error, State<S, Void>>) -> IO<Error, Void>`. If we pay attention to the types of the input an output of this function, we can infer that this function will somehow handle the state transitions, as the `State<S, Void>` "disappears"; therefore, it should be applied within the implementation of this function. In Bow ARch, we will refer to this function as the `StateHandler<S>`.
 
 */
typealias StateHandler<S> = (IO<Error, State<S, Void>>) -> IO<Error, Void>
/*:
 The third function on this list is a well known function; the sensible implementation for this function would be to `unsafeRun` the `IO<Error, Void>` value to perform the described side effects.
 
 ## Representing a user interface
 
 If we step back a bit, our view function was:
 
 `view :: (S, (I) -> Void) -> V`
 
 We have seen that `(I) -> Void` can be decomposed into three parts, from which we can take the second part to take care of the state transitions; we will see later how we plug in the two other pieces. We can rewrite this function as:
 
 `view :: (S, StateHandler<S>) -> V`
 
 And currying this function would yield:
 
 `view :: (S) -> (StateHandler<S>) -> V`
 
 For convenience, we can create a new structure `UI<S, V>`, that is, a `UI` is a function that, when provided a way of handling state transitions, will yield a view.
 
*/
typealias UI<S, V> = (StateHandler<S>) -> V
/*:
 
 So, our view function can be finally rewritten as:
 
 `view :: (S) -> UI<S, V>`
 
 That is, given a state of type `S`, it will provide a user interface that handles state transitions of type `S` and shows this state on a view of type `V`.
 
 ## Describing the space of possible UIs
 
 With the changes we did at the beginning we lost the ability to update the state, as we made the view a function of immutable state. We can restore this ability by making use of the Store Comonad.
 
 A Store definition is:
 */
struct Store<S, A> {
    let state: S
    let render: (S) -> A
}
// nef:begin:hidden
extension Store {
    func extract() -> A {
        render(state)
    }
    
    func duplicate() -> Store<S, Store<S, A>> {
        Store<S, Store<S, A>>(
            state: state,
            render: { s in Store(state: s, render: self.render) }
        )
    }
}
// nef:end
/*:
 Our `view` function has the same shape as the `render` function in Store, and we can restore state handling using the `state` property of Store. Therefore, we can put everything together as:
 
 `store :: Store<S, UI<S, V>>`
 
 This store models the space of all possible UIs that we can have with state `S` and drawn as a view `V`.
 
 ## Performing state transitions
 
 So far we are able to model the space of possible states, but how are state mutations applied? We know that Pairings will help in this regard. The pairing function between State and Store is:
 */
func pair<S, A, B, C>(
    _ fa: State<S, A>,
    _ gb: Store<S, B>,
    _ f: @escaping (A, B) -> C
) -> C {
    let (newS, a) = fa.run(gb.state)
    let b = gb.render(newS)
    return f(a, b)
}
/*:
 We can write a new function in terms of `pair`:
 */
func select<S, B>(
    _ fa: State<S, Void>,
    _ gb: Store<S, Store<S, B>>
) -> Store<S, B> {
    pair(fa, gb) { void, store in store }
}
/*:
 As usual, let's read the types of this function. It receives a state mutation that produces no other value (`State<S, Void>`), and a value `Store<S, Store<S, B>>`.
 
 If a `Store<S, B>` represents the space of possible `B` values that can be rendered from a state `S`, then `Store<S, Store<S, B>>` represents the space of possible spaces of `B` values that can be rendered from an `S` value. It is as if we were able to inspect all possible future states where we can transition to from the current one we are in, and use the State mutation to `select` one of them.
 
 How can we use this now? Well, we haven't still provided an implementation for our `StateHandler<S>` function, and `select` is what we need to do its implementation. We can put everything together as a Component:
 */
class Component<S, V>: ObservableObject {
    @Published var store: Store<S, UI<S, V>>
    
    init(store: Store<S, UI<S, V>>) {
        self.store = store
    }
    
    func explore() -> V {
        // (1) Extract obtains the UI in the current state
        let ui: UI<S, V> = store.extract()
        
        // (2) We provide an implementation of the StateHandler<S>
        //     in order to obtain a view of type V
        return ui { (action: IO<Error, State<S, Void>>) in
            
            // (3) When an action is received,
            //     we access the state mutation
            action.flatMap { (stateMutation: State<S, Void>) in
                
                // (4) Use the mutation to select the next store
                let nextStore: Store<S, UI<S, V>> = select(stateMutation, self.store.duplicate())
                
                // (5) And finally, we update the Store with the next state
                //     that will be rendered
                return IO<Error, Void>.invoke {
                    self.store = nextStore
                }
            }^
        }
    }
}
/*:
 Despite how abstract these concepts are, the process is not very complex. Finally, in order to make sure our SwiftUI rendering updates every time a state transition occurs, we can make:
 */
struct ComponentView<S, V>: View {
    @ObservedObject var component: Component<S, V>
    
    var body: some View {
        self.component.explore()
    }
}
/*:
 Calling explore will obtain the current view for the state saved on the Store. When a user interface event occurs, it will be processed in the flow above, will trigger a new Store, and the `ObservedObject` property wrapper will notice a change, that will result in a new rendering of the UI.
 
 ## Generalizing these ideas
 
 So far we have described how these ideas are applicable for State and Store; however, the reasoning can be generalized, as the "magic" of this approach resides on the notion of Pairing between a Monad and a Comonad.
 
 In fact, the `explore` function does not need to know it is dealing with State and Store; it just uses a `select` function, which is a function that can be derived from `pair`. Therefore, `explore` can be written as a generic function that operates on a Comonad, and its Pairing Monad.
 
 If we take this approach, we can review our entire reasoning to define the building blocks of the Comonadic UIs approach as using a Monad `M` and a Comonad `W` that pair with each other:
 
 - `Handler<M: Monad> :: (IO<Error, M<Void>>) -> IO<Error, Void>`
 - `UI<M: Monad, V> :: (Handler<M>) -> V`
 - `Component<W: Comonad, M: Monad, V> :: W<UI<M, V>>`
 
 Moreover, we are using `IO` to model side effects here, but nothing stops us to abstract over this as well. We could be using other type to deal with side effects. In this case, if we use an abstract `Eff` type, the final result is:
 
 - `Handler<Eff, M> :: (Eff<M<Void>>) -> Eff<Void>`
 - `UI<Eff, M, V> :: (Handler<Eff, M>) -> V`
 - `Component<Eff, W, M, V> :: W<UI<Eff, M, V>>`
 
 With this model, we can yield different architectures, letting us choose the type we will use to model side effects (`Eff`), the type to model UI actions (`M`) and the space of possible UIs (`W`).
 
 ## Conclusion
 
 Bow Arch provides a general implementation of this model, and additional syntax sugar over the State-Store pair, which will ease the usage of the library.
 
 The actual implementation is a bit more complex, but not too much; concepts presented here have been simplified for the sake of pedagogy.
 
 Do not worry if you do not get it on the first read. It will take time for the ideas to percolate, and you will discover new things every time you read these docs. An effective way of understanding it is to actually try to write the code, at least in a non-generic way. It will help you see these concepts in practice. And if you get stuck, feel free to open an issue on the library repository, or contact the developers of the library.
 */
