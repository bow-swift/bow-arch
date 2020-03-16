import SwiftUI
import Bow
import BowEffects

public typealias EffectStoreTComponent<Eff: Async, WW: Comonad, MM: Monad, S, V: View> = EffectComponentView<Eff, StoreTPartial<S, WW>, StateTPartial<MM, S>, V>
public typealias EffectStoreComponent<Eff: Async, S, V: View> = EffectStoreTComponent<Eff, ForId, ForId, S, V>
