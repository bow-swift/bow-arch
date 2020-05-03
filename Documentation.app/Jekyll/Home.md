---
layout: docs
title: Home
permalink: /docs/
---

# Bow Arch

Bow Arch is a highly opinionated library to architect SwiftUI applications in a purely functional manner. It has a solid theoretical background behind it, whilst users of the library do not need to be proficient in such details to use it to its full power.

Bow Arch is based on the following principles:

## 🎨 View as a function of state

Using SwiftUI, we can create user interfaces in a declarative manner, that are a representation of a given state. The library goes even further and promotes the creation of views that are based on immutable state.

## 🚧 Clear separation of concerns

The core concepts int the library are state, action, dispatcher, view, and component. Each one of them deals with a specific concern, and lets us separate how our code deals with different aspects of application development.

## 📦 Modularity

The library promotes the creation of components that can be easily reused across the application, or even in other applications. These components are highly composable and let us manage the complexity of large applications.

## ✅ Testability

Functional code is intrinsically testable; therefore, software created with Bow Arch is easy to test. The library also provides utilities that you can leverage to write powerful and expressive tests.

## 🧩 Highly polymorphic

The library is based on abstract, parameterized artifacts. This makes this library not only a library to architect your application, but a library to create different architectures by replacing each of these parameters. Nevertheless, specific bindings are provided in the library, so that users do not have to deal with these details.

## 🧮 Mathematical background

Bow Arch is based on concepts from Category Theory, which brings soundness to the reasoning we can do about our code. Nonetheless, the API of the library hides the complexity of these concepts and users do not need to be experts in this topic to use the library in their applications.
