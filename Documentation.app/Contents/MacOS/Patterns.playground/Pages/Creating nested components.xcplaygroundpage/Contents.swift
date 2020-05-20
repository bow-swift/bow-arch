// nef:begin:header
/*
 layout: docs
 title: Creating nested components
 */
// nef:end
// nef:begin:hidden
import SwiftUI
import Bow
import BowEffects
import BowOptics
import BowArch
// nef:end
/*:
 # Creating nested components
 
 Usually, you will need to create new components in terms of others with lower granularity. This page covers the most important aspects you need to consider when composing different components.
 
 ## Creating a parent view
 
 As components conform to `View`, nothing stops you from adding them to your SwiftUI views. Therefore, assuming you already have a `ChildComponent`, you can easily add it to your view hierarchy:
 */
// nef:begin:hidden
struct ChildDependencies {}
struct ChildState {}
enum ChildInput {}
struct ChildView: View {
    var body: some View {
        EmptyView()
    }
}
typealias ChildComponent = StoreComponent<ChildDependencies, ChildState, ChildInput, ChildView>

struct ParentState {
    let childState: ChildState
    
    static var childLens: Lens<ParentState, ChildState> = Lens(
        get:  \.childState, set: { ParentState(childState: $1) })
}

enum ParentInput: AutoPrism {
    case childInput(ChildInput)
}

struct ParentDependencies {
    let childDependencies: ChildDependencies
}

class Snippet1 {
// nef:end
struct ParentView: View {
    let state: ParentState
    let child: ChildComponent
    
    var body: some View {
        VStack {
            // ... Some views ...
            
            child
            
            // ... Some views ...
        }
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 However, this forces to build the `ChildComponent` if, for instance, we would like to create a preview of `ParentView`. An alternative way of doing this is by parameterizing the `ParentView`:
 */
// nef:begin:hidden
class Snippet2 {
// nef:end
struct ParentView<Child: View>: View {
    let state: ParentState
    let child: Child
    
    var body: some View {
        VStack {
            // ... Some views ...
            
            child
            
            // ... Some views ...
        }
    }
}
// nef:begin:hidden
}
// nef:end
/*:
 With this small change, we can now pass the ChildComponent, or any other stub view that we want in order to render the preview.
 
 One additional step we can take is to pass a function that, given the child state, builds the corresponding component. This is particularly useful when we are dealing with collections of items.
 */
struct ParentView<Child: View>: View {
    let state: ParentState
    let child: (ChildState) -> Child
    let handle: (ParentInput) -> Void
    
    var body: some View {
        VStack {
            // ... Some views ...
            
            child(self.state.childState)
            
            // ... Some views ...
        }
    }
}
/*:
 ## Creating a global dispatcher
 
 Next, both child and parent will have their own Dispatchers to interpret view inputs into state mutations. Those Dispatchers need to be combined into a single one. However, types of both dispatchers do not match:
 */
typealias ChildDispatcher = StateDispatcher<ChildDependencies, ChildState, ChildInput>

typealias ParentDispatcher = StateDispatcher<ParentDependencies, ParentState, ParentInput>
/*:
 In order to combine them, first we need to match their type signatures. As the `ChildDependencies`, `ChildState` and `ChildInput` are embedded into `ParentDependencies`, `ParentState` and `ParentInput` respectively, we can `widen` the `ChildDispatcher` to embed each parameter into its corresponding slot in the parent:
 */
// nef:begin:hidden
let childDispatcher = ChildDispatcher.workflow { _ in [] }
let parentDispatcher = ParentDispatcher.workflow { _ in [] }
// nef:end

let widenChildDispatcher: ParentDispatcher =
    childDispatcher.widen(
        transformEnvironment: \.childDependencies,
        transformState: ParentState.childLens,
        transformInput: ParentInput.prism(for: ParentInput.childInput))

let combinedDispatcher = parentDispatcher.combine(widenChildDispatcher)
/*:
 ## Assembling the parent component
 
 Finally, when you create the parent component, you will need to forward the inputs that happen on the child component to the parent component, as some of these inputs may be relevant to other components that are upstream in the view hierarchy.
 */
// nef:begin:hidden
typealias ParentComponent = StoreComponent<ParentDependencies, ParentState, ParentInput, ParentView<ChildComponent>>

func childComponent(_ state: ChildState) -> ChildComponent {
    fatalError()
}
// nef:end

func parentComponent(
    initialState: ParentState,
    dependencies: ParentDependencies
) -> ParentComponent {
    ParentComponent(
        initialState: initialState,
        environment: dependencies,
        dispatcher: combinedDispatcher,
        render: { state, handle in
            ParentView(
                state: state,
                child: { childState in
                    childComponent(childState)
                        .using(handle,
                               transformInput: ParentInput.prism(for: ParentInput.childInput))
                },
                handle: handle)
        }
    )
}
