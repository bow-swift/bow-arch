import SwiftUI
import Bow
import BowEffects

public typealias EffectMooreComponent<Eff: Async, Action, V: View> = EffectComponentView<Eff, MoorePartial<Action>, ActionPartial<Action>, V>
