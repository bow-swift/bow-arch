// nef:begin:header
/*
 layout: docs
 title: View
 */
// nef:end
// nef:begin:hidden
import SwiftUI
// nef:end
/*:
 # View
 
 Views in BowArch are pure SwiftUI views that render the user interface as a function of immutable state. There is no restriction from Bow Arch on how you can build your View, and it is totally up to your particular app.
 
 Commonly, your view will receive two parameters:
 
 - A state, that you need to store as a field, and contains the information you need to render the view.
 - A function, that you can invoke whenever an input happens on the view.
 
 The state refers to the application state and it is immutable; that is, you must not mutate it, and do not need to store it with an `@State` property wrapper. Bow Arch will take care of its modification whenever an action triggers it.
 
 Your view may have other fields to hold its own internal state, that is not relevant to the application state. Those fields may be annotated with `@State` or `@Binding` if necessary.
 
 The view can also be decomposed into multiple, smaller views, in order to handle its complexity, and be able to reuse them as much as possible.
 
 ## Example
 
 As an example, we can build a stepper view. Given the following structures modeling state and input:
 */
struct StepperState {
    let count: Int
}

enum StepperInput {
    case tapDecrement
    case tapIncrement
}
/*:
 We can build the View as:
 */
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
 Inputs provided in this View will be received by a Dispatcher, which will trigger the corresponding actions to modify the state. This way, our view remains a pure function of state, and it is completely decoupled of the business logic.
 */
