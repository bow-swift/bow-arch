// nef:begin:header
/*
 layout: docs
 title: Dispatcher
 */
// nef:end
// nef:begin:hidden
import BowArch
// nef:end
/*:
 # Component
 
 Components in Bow Arch put everything together. They manage to render a **State** in a **View**, which eventually produces **Inputs**, that are transformed by a **Dispatcher** into actions that modify the state, closing the loop. This is a unidirectional loop where each artifact has clear responsibilities and are build in a purely functional manner. That way, everything is easy to manage, can be tested in isolation, and is highly composable.
 
 Components are parameterized with four types:
 
 - Environment: the dependencies it needs to run state updates.
 - State: the state it needs to handle.
 - Input: the type of inputs that are produced within the component.
 - View: the SwiftUI view that renders its user interface.
 
 Therefore, to create a component, you need to provide:
 
 - An initial state.
 - A data structure with the dependencies it needs.
 - A dispatcher that transforms inputs into actions.
 - A view that renders the state.
 
 From this initial configuration, it will handle state changes and updates to the UI as a black box. Components conform to SwiftUI `View`, so they can be used as part of other views, or as the root view of a `UIHostingController`.
 */
