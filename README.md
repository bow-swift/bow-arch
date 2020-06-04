![Bow Arch](assets/header-bow-arch.png)

<p align="center">
<a href="https://github.com/bow-swift/nef">
<img src="https://img.shields.io/badge/Dependency%20Manager-Swift%20PM-orange" alt="SPM compatible">
</a>

<a href="https://gitter.im/bowswift/bow">
<img src="https://img.shields.io/badge/Gitter-Bow%20Arch-yellow" alt="Gitter">
</a>

<img src="https://img.shields.io/badge/platform-macOS%20%7C%20iOS-yellow">

<img src="https://github.com/bow-swift/bow-arch/workflows/Deploy%20docs/badge.svg?branch=master">
</p>

Welcome to Bow Arch!

**Bow Arch** is a library to [architect applications in pure Functional Programming](https://arch.bow-swift.io/docs/quick-start/getting-started/), based on the notion of [Comonadic User Interfaces](https://arch.bow-swift.io/docs/background/comonadic-uis/). Please, refer to the [project website](https://arch.bow-swift.io) for extensive documentation.

&nbsp;

## 👩‍🏫 Principles

🎨 **View as a function of state**: Using SwiftUI, we can create user interfaces in a declarative manner, that are a representation of a given state. The library goes even further and promotes the creation of views that are based on immutable state.

🚧 **Clear separation of concerns**: The core concepts in the library are [state](https://arch.bow-swift.io/docs/core-concepts/state-and-input/), [input](https://arch.bow-swift.io/docs/core-concepts/state-and-input/), [dispatcher](https://arch.bow-swift.io/docs/core-concepts/dispatcher/), [view](https://arch.bow-swift.io/docs/core-concepts/view/), and [component](https://arch.bow-swift.io/docs/core-concepts/component/). Each one of them deals with a specific concern, and lets us separate how our code deals with different aspects of application development.

📦 **Modularity**: The library promotes the [creation of components](https://arch.bow-swift.io/docs/patterns/creating-a-single-component/) that can be easily reused across the application, or even in other applications. These components are highly composable and let us manage the complexity of large applications.

✅ **Testability**: Functional code is intrinsically testable; therefore, software created with Bow Arch is easy to test. The library also provides utilities that you can leverage to write powerful and expressive tests.

🧩 **Highly polymorphic**: The library is based on abstract, parameterized artifacts. This makes this library not only a library to architect your application, but a library to create different architectures by replacing each of these parameters. Nevertheless, specific bindings are provided in the library, so that users do not have to deal with these details.

🧮 **Mathematical background**: Bow Arch is based on concepts from Category Theory, which brings soundness to the reasoning we can do about our code. Nonetheless, the API of the library hides the complexity of these concepts and users do not need to be experts in this topic to use the library in their applications.

&nbsp;

## 💻 How to get it

Bow Arch is available through Swift Package Manager, integrated in Xcode. You only need to use the repository URL on GitHub and the version or branch you would like to use. Alternatively, you can describe this dependency in your `Package.swift` file by adding the line:

 ```swift
 .package(url: "https://github.com/bow-swift/bow-arch.git", from: "{version}")
 ```

&nbsp;

## 👨‍💻 Usage

Bow Arch lets you architect your application in terms of components that can be reused across applications. Let's go over what you need to create in order to build a stepper component.

### 📋 State

A component should have a state that is rendered in its view. State is usually modeled using an immutable data structure, typically a `struct`.

For our stepper component, we can model our state as:

```swift
struct StepperState {
    let count: Int
}
```

### 📲 Input

Next step is modeling inputs that a component can handle. Inputs are usually described using cases of an `enum`.

In our ongoing example, the component can receive two inputs, corresponding to tapping on the decrement or increment buttons. These can be modeled as:

```swift
enum StepperInput {
    case tapDecrement
    case tapIncrement
}
```

### 🎨 View

With state and input defined, we can render a view using SwiftUI. SwiftUI is a declarative framework to describe user interfaces in Swift, with multiple bindings for the different operating systems in the Apple Platforms.

We can describe the view as a function of its state, and use a function to receive inputs:

```swift
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
```

### 🔨 Dispatcher

Inputs new to be transformed into actions that modify the state. This is done at the Dispatcher. Dispatchers are pure functions that receive inputs and produce actions:

```swift
typealias StepperDispatcher = StateDispatcher<Any, StepperState, StepperInput>

let stepperDispatcher = StepperDispatcher.pure { input in
    switch input {
    case .tapDecrement:
        return .modify { state in
            StepperState(count: state.count - 1)
        }^

    case .tapIncrement:
        return .modify { state in
            StepperState(count: state.count + 1)
        }^
    }
}
```

### 🧩 Component

Finally, we can put everything together as a component:

```swift
typealias StepperComponent = StoreComponent<Any, StepperState, StepperInput, StepperView>

let stepperComponent = StepperComponent(
    initialState: StepperState(count: 0),
    dispatcher: stepperDispatcher,
    render: StepperView.init)
```

Components already conform to SwiftUI `View`, so they can be used as part of other views, or assigned as the root view of a `UIHostingController`.

```swift
let controller = UIHostingController(rootView: stepperComponent)
```

&nbsp;

## 👏 Acknowledgements

We want to thank [Arthur Xavier](https://github.com/arthurxavierx/purescript-comonad-rss/blob/master/RealWorldAppComonadicUI.pdf), [Phil Freeman](https://functorial.com/the-future-is-comonadic/main.pdf), and [Edward Kmett](https://hackage.haskell.org/package/comonad), for their previous work on Comonads and Comonadic UIs in the PureScript and Haskell languages. The usage of optics to break down and compose components is inspired by the use of index and case paths in the [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) by Stephen Cellis and Brandon Williams. Their work has inspired the creation of this library.

&nbsp;

## ⚖️ License

    Copyright (C) 2020 The Bow Authors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
