// nef:begin:header
/*
 layout: docs
 title: Overview
 */
// nef:end
/*:
 # Theoretical background
 
 This section describes the theoretical background behind Bow Arch. This library is based on concepts from a branch of Mathematics called Category Theory, which provides solid grounds to Functional Programming through a number of abstractions that obey a set of rules, and help us reason about our code.
 
 In particular, this library is based on the works done in PureScript by Phil Freeman - [Declarative UIs are the Future, and the Future is Comonadic!](https://functorial.com/the-future-is-comonadic/main.pdf) - and Arthur Xavier - [A Real World Application with a Comonadic User Interface](https://github.com/arthurxavierx/purescript-comonad-rss/blob/master/RealWorldAppComonadicUI.pdf). Some of the abstractions are also inspired by the [Haskell Comonads package](https://hackage.haskell.org/package/comonad), developed by Edward Kmett. To all of them, we want to express our deepest gratitude.
 
 As you could guess, implementing these abstractions is not trivial, especially considering that Swift does not have Higher Kinded Types, nor existential quantifiers. These limitations have been partially overcome using emulation of HKTs in [Bow](https://bow-swift.io). The core abstractions - the Comonad package - are included in that library, as they can serve to other purposes; whereas their composition to create architectural components are included in Bow Arch.
 
 ## Why should I bother learning this?
 
 Understanding the theory behind the library is interesting and will give you a new perspective of its power, and the possibilities behind it. However, this is not necessary to be able to use the library to build complex applications.
 
 Software engineers have come up with many proposals to architect frontend applications in a functional manner. Examples of these are [Redux](https://redux.js.org/) or [Elm](https://guide.elm-lang.org/architecture/), or in the Swift community, [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).
 
 Comonadic UIs are a generalization over these architectures, showing that most of the ideas that have appeared from intuition, actually have a solid background that support their validity. The aim of Bow Arch is to show these ideas in action, and how using different Comonads yields new ways of architecting applications, that are better suited for certain interaction patterns.
 
 As stated above, learning about Comonadic UIs is not necessary to be proficient at using Bow Arch or any other architectural library, but it will broaden your understanding of the architectural decisions that you are making, and you will be able to make more solid decisions when designing your applications.
 */
