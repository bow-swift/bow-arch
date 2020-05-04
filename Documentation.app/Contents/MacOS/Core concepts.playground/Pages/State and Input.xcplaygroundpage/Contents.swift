// nef:begin:header
/*
 layout: docs
 title: State and Input
 */
// nef:end
// nef:begin:hidden
import BowArch
import BowOptics
// nef:end
/*:
 # State and Input
 
 Bow Arch encourages a strong modeling of the problem domain to capture the state and inputs of a component into immutable data structures, that are usually designed as Algebraic Data Types.
 
 How you model state and inputs is very dependent on your particular project. However, as a general guideline, state is usually modeled using a product type, and inputs are usually modeled as a sum type.
 
 Product types in Swift can be represented using structs, tuples or classes, and while being isomorphic, each one of them have different semantics and/or ergonomics:
 
 - Structs: provide value semantics, are final (no inheritance allowed), and mutability has to be marked explicitly.
 - Classes: provide reference semantics, can be extended, and mutability is not explicit.
 - Tuples: provide value semantics, but are not nominal types; therefore, we cannot add methods to them in an extension.
 
 Typically, modeling state with structs will be our preferred choice.
 
 As for Sum types, Swift provides enums to represent them. Swift enums can have associated values that will be the companion data we need to perform an action for the input they represent.
 
 ## Parent-child relationships
 
 Both state and input of a given component need to be captured in its parent state and input. That is, the parent state should have a field representing the child state; similarly, the parent input should have a case representing the child input.
 
 ## Accessing and modifying immutable data
 
 We have made a strong emphasis in modeling state and input as immutable data structures. How should you access and modify them? The answer is optics.
 
 [Optics](https://bow-swift.io/next/docs/optics/optics-overview/) are algebraic structures that let us work with immutable data structures in a functional way, and are highly composable. In particular, the optics that we will need are:
 
 - **Lenses**: they are optics to work with product types that let us view and modify a part of a data structure.
 - **Prisms**: they are optics to work with sum types that let us extract or embed a case of a data structure.
 
 You can use Bow Optics to [write your own lenses and prisms](https://bow-swift.io/next/docs/optics/writing-your-own-optics/), or [get them automatically generated](https://bow-swift.io/next/docs/optics/automatic-derivation/), to work with your data structures.
 
 ## Example
 
 Consider an app that renders a home screen with a user profile and a list of articles. Tapping on the user profile goes to a new screen to show a detail of the user profile, where we can perform editions.
 
 We can model state as:
 */
struct UserProfile {
    let name: String
    let picture: URL
}

struct Article {
    let title: String
    let content: String
    let publicationDate: Date
    let isFavorite: Bool
}
/*:
 State is then grouped into the parent state:
 */
struct HomeScreen {
    let profile: UserProfile
    let articles: [Article]
}
/*:
 Similarly, we can model inputs as:
 */
enum UserProfileInput {
    case changePicture(URL)
    case changeName(String)
}

enum ArticleInput {
    case markFavorite(Article)
}
/*:
 Inputs can also be grouped into a parent input:
 */
enum HomeScreenInput {
    case userProfile(UserProfileInput)
    case article(ArticleInput)
}
/*:
 We can write a lens to access the user profile from a home screen:
 */
let userProfileLens = Lens<HomeScreen, UserProfile>(
    get: { home in home.profile },
    set: { home, newProfile in HomeScreen(profile: newProfile, articles: home.articles) }
)
/*:
 Likewise, we can write a prism to access the user profile input from a home screen input:
 */
let userProfilePrism = Prism<HomeScreenInput, UserProfileInput>(
    extract: { homeInput in
        guard case let .userProfile(input) = homeInput else {
            return nil
        }
        return input
    },
    embed: HomeScreenInput.userProfile
)
