// nef:begin:header
/*
 layout: docs
 title: Monads and Comonads
 */
// nef:end
/*:
 # Monads and Comonads
 
 Monads are probably the most dreaded concept by newcomers to Functional Programming. They have a lesser known counterpart, Comonads, which happen to have a very special relationship with Monads. This page does not aim to be a tutorial on Monads and Comonads; rather, we will try to build an intuition of what they are, by reading the operations included in these type classes, and the types involved in them.
 
 ## Monads
 
 In Category Theory, Monads are defined as *Monoids in the Category of Endofunctors*. This definition, although correct, is mostly useless in software development. What we need to consider is what are the requirements for something to behave as a Monad.
 
 First thing we need to point out is that Monads cannot be represented as an abstraction in Swift; the Monad type class is an abstraction that works at a Higher Kind level. That is, it must be conformed by a type `F<A>`, for all `A`. Unfortunately, this is not possible to be expressed in Swift. Bow provides an emulation of Higher Kinded Types that will let us describe this abstraction.
 
 Then, in programming, the Monad type class requires the implementation of two functions:
 
 - `pure` or `return`: `(A) -> F<A>`
 - `flatMap`, `bind` or `>>=`: `(F<A>, (A) -> F<B>) -> F<B>`
 
 In ocasions, instead of `flatMap`, you could implement:
 
 - `flatten`: `(F<F<A>>) -> F<A>`
 
 `flatMap` and `flatten` can be implemented in terms of each other; therefore, in order to have an implementation of a Monad, you must provide implementations of `pure`, and `flatMap` or `flatten`. In Bow, you will always be required to implement `pure` and `flatMap`.
 
 Let's look at the types of each required function. `pure` is a function `(A) -> F<A>`. That is, given any value, the `pure` function can lift it to the context of the `Monad`. In this sense, we can say that monadic operations "introduce context".
 
 `flatMap` is a function `(F<A>, (A) -> F<B>) -> F<B>`. It has two arguments: `F<A>`, which we can read as "a value in the context of the Monad"; and a function `(A) -> F<B>`, which we can read as "a function to produce a new value in the context of the Monad". Looking at the return type, `F<B>`, the only way we can obtain it is by running the function provided as an argument, but to do so, we need a value of type `A`. We can somehow obtain an `A` from the first argument, given that it exists in the context of the Monad. Therefore, intuitively, the `flatMap` operation lets us perform two effects sequentially, when the second (`F<B>`) depends on the first (`F<A>`). In this way, we can say that Monads let us "chain dependent effects sequentially".
 
 In summary, from this intuition we can say that Monads introduce context in the operations they are involved, and let us chain effects sequentially.
 
 ### Example
 
 One example of a Monad that is pervasively used throughout the library is State. `State<S, A>` represents a function `(S) -> (S, A)`; that is, a function that receives a value of the state model, and produces a tuple with a modification of the provided state, and an output value of type `A`. State is used to represent computations that depend on a certain state, without having to thread it explicitly through all operations.
 */
struct State<S, A> {
    let run: (S) -> (S, A)
}
/*:
 It's instance of the Monad type class (its implementation) is pretty straigthforward. Let's begin with `pure`: given any value of type `A`, we can always provide a `State<S, A>`, that does not modify the passed state:
 */
extension State {
    static func pure(_ a: A) -> State<S, A> {
        State { s in (s, a) }
    }
}
/*:
 As for `flatMap`, we mentioned that, from our intuition, we are sequencing two operations, where the second one depends on the result of the first. That means we should run the first State, obtain the modified state and the output, and feed it to the second:
 */
extension State {
    func flatMap<B>(_ f: @escaping (A) -> State<S, B>) -> State<S, B> {
        State<S, B> { s in
            let (newS, a) = self.run(s)
            return f(a).run(newS)
        }
    }
}
/*:
 ## Comonads
 
 Similarly, Comonads could be defined as *Comonoids in the Category of Endofunctors*, which is an equally useless definition in software development. Comonads the dual structure of Monads, obtained by reversing the arrows in Category Theory.
 
 As Monads, Comonads work at the Higher Kind level, and are only possible to be represented using the emulation provided by Bow. They require the implementation of the following requirements:
 
 - `extract`: `(F<A>) -> A`
 - `coflatMap` or `extend`: `(F<A>, (F<A>) -> B) -> F<B>`
 
 Sometimes, instead of `coflatMap`, you could implement:
 
 - `duplicate`: `(F<A>) -> F<F<A>>`
 
 `coflatMap` and `duplicate` can be implemented in terms of one another; thus, you need to implement `extract`, and `coflatMap` or `duplicate`, to have an implementation of a Comonad. In Bow, you will always have to implement `extract` and `coflatMap`.
 
 By now, you may have already noticed some symmetry between Monads and Comonads, but let's look at the types of the functions in order to build some sort of intuition behind them.
 
 `extract` is a function `(F<A>) -> A`, which, if you pay attention, is just the opposite of `pure`. That is, given a value in the context of the Comonad, we are able to extract that value out of the context. This tells us the Comonad represents some kind of space, but it is focused on a specific point of such space, which we can always obtain.
 
 `coflatMap` is a function `(F<A>, (F<A>) -> B) -> F<B>`. That is, we need to return an `F<B>`, which as we have mentioned above, can be seen as a space of values of type `B`. The only way we can obtain values of type `B` is by the function `(F<A>) -> B`, but an invocation of this function gives us a single point `B` in our space. This suggests we will need to invoke this function potentially multiple times to build the space of `F<B>`, and each time, it consumes the context provided by `F<A>`. Therefore, `coflatMap` lets us perform an operation `(F<A>) -> B` that consumes the context of `F<A>`, in all posible foci its space of values, to produce a new space of values.
 
 In summary, Comonads let us perform operations that are context-dependent, and extract their focused results.
 
 ### Example
 
 Store is also used extensively in Bow Arch. `Store<S, A>` wraps two things: a value of type `S`, known as the `state`, and a function of type `(S) -> A`, known as `render`.
 */
struct Store<S, A> {
    let state: S
    let render: (S) -> A
}
/*:
 From the intuition we built before, we said a Comonad represents a space of values. Such space is represented by the `render` function in the Store. It models all possible `A` values that could be potentially rendered by this Store. Also, we mentioned that Comonads are somehow focused on a specific point of such space; in Store, that focus is the `state`.
 
 How does its Comonoad instance look like? The `extract` function should be easy to implement: just apply the `render` function to the current `state`:
 */
extension Store {
    func extract() -> A {
        self.render(self.state)
    }
}
/*:
 The implementation for `coflatMap` may be a bit more cumbersome to understand. We need to provide a `Store<S, B>`. The `state` property for such Store is the same `state` of the receiver Store, as we have no other way of getting such value.
 
 Regarding the `render` function, we need a function `(S) -> B`. The only thing we have to obtain a `B` is the provided function `(Store<S, A>) -> B`. Therefore, we can construct a new Store with the `render` function of `Store<S, A>`, and pass it to the provided function.
 */
extension Store {
    func coflatMap<B>(_ f: @escaping (Store<S, A>) -> B) -> Store<S, B> {
        Store<S, B>(
            state: self.state,
            render: { s in
                f(Store(state: s, render: self.render))
            })
    }
}
/*:
 As you can see, the function `(Store<S, A>) -> B` is providing us a specific point of the new space in `Store<S, B>`, and when we do a `coflatMap`, we are potentially exploring all possible contexts (with the new `render` function) to build the space of `Store<S, B>`.
 
 Stores are focused on a specific state, but also provide methods to change that focus, to render a different point of the space of options they model.
 */
