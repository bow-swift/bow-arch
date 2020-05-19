// nef:begin:header
/*
 layout: docs
 title: Pairings
 */
// nef:end
/*:
 # Pairings
 
 Monads and Comonads are dual structures in Category Theory, and their connection can go even beyond that. Specific instances of Monads and Comonads can have a relationship between each other that will yield interesting results. That relationship is known as Pairing, and let us combine a Monad and its corresponding Comonad.
 
 We have mentioned that Comonads represent a space of options, from which one of these options is selected at a given moment. On the other hand, Monads model actions that produce a new context. A Pairing is a combination of a Monad and a Comonad in such a way that we can use values of the Monad to somehow navigate the space represented by the Comonad. This is done by implementing a function with the following signature:
 
 `pair: (F<A>, G<B>, (A, B) -> C) -> C`
 
 That is, given a Monad `F` producing values of type `A`, a Comonad `G` producing values of type `B`, and a way of combining `A` and `B` into `C`, the pair function can somehow extract the values of `A` and `B` from their corresponding Monad and Comonad, and combine them. Notice that this is not always possible; it implies that there must be some sort of relationship between `F` and `G` to be able to do this.
 
 ### Example
 
 By now this should look very abstract to you, so let's try to illustrate it with an example, using State and Store.
 
 If we look at State, it represents a function `(S) -> (S, A)`; therefore, we cannot extract an `A` from it by only using what we have inside it. However, if we pair it with a Store, we can use the `state` value stored in the Store to run the State function, obtain an `A` value, and render the new state to obtain a `B` value.
 
 With this, the implementation of `pair` for State and Store could look like:
 */
// nef:begin:hidden
struct State<S, A> {
    let run: (S) -> (S, A)
}

struct Store<S, A> {
    let state: S
    let render: (S) -> A
}
// nef:end
func pair<A, B, C, S>(
    _ fa: State<S, A>,
    _ gb: Store<S, B>,
    _ f: @escaping (A, B) -> C
) -> C {
    let (newS, a) = fa.run(gb.state)
    let b = gb.render(newS)
    return f(a, b)
}
/*:
 As you can see, we have taken the current state of the Store, and used State to transition it to a new state, that is then rendered. Therefore, this shows we can use values of State to perform actions that navigate the space described by Store.
 
 ## Existing Pairings
 
 Besides the State-Store pairing, there are others that can be found. Examples of these are Writer-Traced or Reader-Env, and you can take a look at their implementation in the Bow repository.
 
 Is it always possible to write a Pairing for a Monad and a Comonad? It turns out that there is an important result that shows that for a given Comonad, there is always a Monad that pairs with it. However, the reverse is not necessarily true; that is, given a Monad, there may not be a Comonad that pairs with it.
 
 In the cases we have seen so far, for Comonads Store, Traced and Env, their corresponding pairing Monads exist and are well known. However, there are Comonads whose pairing Monads may not be so well known. How can we pair them?
 
 There is an interesting type known as `Co`, or `Transition`, which, given any Comonad, it will yield its corresponding pairing Monad. Even in the cases we already know, like Store, we could get a Co-Store that will behave exactly like State.
 */
