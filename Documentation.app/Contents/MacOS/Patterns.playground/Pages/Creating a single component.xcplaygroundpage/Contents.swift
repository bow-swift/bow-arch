// nef:begin:header
/*
 layout: docs
 title: Creating a single component
 */
// nef:end
/*:
 # Creating a single component
 
 Bow Arch lets you architect your application in terms of components that can be reused across applications. Let's go over what you need to create in order to build a stepper component.
  
  ## 📋 State
  
  A component should have a state that is rendered in its view. State is usually modeled using an immutable data structure, typically a `struct`.
  
  For our stepper component, we can model our state as:
  */
 struct StepperState {
     let count: Int
 }
 /*:
  ## 📲 Input
  
  Next step is modeling inputs that a component can handle. Inputs are usually described using cases of an `enum`.
  
  In our ongoing example, the component can receive two inputs, corresponding to tapping on the decrement or increment buttons. These can be modeled as:
  */
 enum StepperInput {
     case tapDecrement
     case tapIncrement
 }
 /*:
  ## 🎨 View
  
  With state and input defined, we can render a view using SwiftUI. SwiftUI is a declarative framework to describe user interfaces in Swift, with multiple bindings for the different operating systems in the Apple Platforms.
  
  We can describe the view as a function of its state, and use a function to receive inputs:
  */
 import SwiftUI

 struct StepperView: View {
     let state: StepperState
     let handle: (StepperInput) -> Void
     
     var body: some View {
         HStack {
             Button("-") {
                 self.handle(.tapDecrement)
             }
             
             Text("\(state.count)")
             
             Button("+") {
                 self.handle(.tapIncrement)
             }
         }
     }
 }
 /*:
  ## 🔨 Dispatcher
  
  Inputs new to be transformed into actions that modify the state. This is done at the Dispatcher. Dispatchers are pure functions that receive inputs and produce actions:
  */
 typealias StepperDispatcher = StateDispatcher<Any, StepperState, StepperInput>

 let stepperDispatcher = StepperDispatcher.pure { input in
     switch input {
     case .tapDecrement:
         return .modify { state in
             StepperState(count: state.count - 1)
         }^
     
     case .tapIncrement:
         return .modify { state in
             StepperState(count: state.count + 1)
         }^
     }
 }
 /*:
  ## 📦 Component
  
  Finally, we can put everything together as a component:
  */
 typealias StepperComponent = StoreComponent<Any, StepperState, StepperInput, StepperView>

 let stepperComponent = StepperComponent(
     initialState: StepperState(count: 0),
     dispatcher: stepperDispatcher,
     render: StepperView.init)
 /*:
  Components already conform to SwuiftUI `View`, so they can be used as part of other views, or assigned as the root view of a `UIHostingController`.
  */
