# Spinora 🎰⚔️

**Spinora** is a thrilling iOS rogue-like RPG built natively with Swift, SwiftUI, and SpriteKit. The game brilliantly merges the unpredictability of slot machine mechanics with strategic, elemental-based combat. Players embark on an endless survival journey where every spin of the reel dictates their power, and every cleared wave introduces increasingly challenging enemies.

---

## 🌟 Key Features

* **Strategic Slot Combat**: Spin the 3-slot elemental reels to determine your attack. Land combinations of **Fire**, **Water**, and **Earth** to execute your moves and deal devastating damage to your opponents.
* **Elemental Weakness System**: Master the combat triangle:
  * 💧 **Water** beats 🔥 **Fire** (2.0x Damage)
  * 🔥 **Fire** beats 🪨 **Earth** (2.0x Damage)
  * 🪨 **Earth** beats 💧 **Water** (2.0x Damage)
* **Dynamic Combo Multipliers**: Landing multiple identical elements in a single spin stacks your damage. Hit a "Jackpot" (3 of the same element in one spin) to unleash a massive combo multiplier to instantly crush your foes!
* **Endless Roguelike Progression**: Battle through infinite waves of enemies. Both you and the monsters grow mathematically stronger as the stages progress. Watch out for every 5th wave—the enemies will receive a massive "Boss" power spike that will test your limits.
* **Rewarding Gacha Upgrades**: After successfully clearing a wave, you get to choose your reward path. Will you boost your Max HP to survive longer, or enhance your Base Attack to hit harder? Each reward offers a guaranteed base stat increase alongside a randomized 1% - 3% gacha bonus.
* **Seamless Auto-Save**: Built with a robust persistence system (`SwiftData`), your current run, highest wave, and accumulated stats are always saved. You can safely close the app at any time and resume your run exactly where you left off.

---

## 🛠 Tech Stack

* **Language**: Swift
* **UI Framework**: SwiftUI
* **Game Engine / Animations**: SpriteKit (for fluid 2D reel animations and battle effects)
* **Local Persistence**: SwiftData (seamless saving of `SavedRunModel`, `RunUpgradeModel`, etc.)
* **Architecture**: MVVM (Model-View-ViewModel)

---

## 📂 Project Architecture

* **Models**: Contains core logic, data structures, and the elemental combat mathematics (e.g., `Element.swift`, `DamageCalculator.swift`, `BattleLayoutData.swift`).
* **ViewModels**: Houses the state and business logic of the game, managing transitions between waves, combat turns, and calculating stat growths (e.g., `GameLayoutViewModel.swift`).
* **Views**: The declarative UI constructed in SwiftUI (e.g., `GameBattleView.swift`, `GameOverlayView.swift`, and modular UI components).
* **SpriteKit**: Dedicated nodes and scenes for high-performance visual effects like the spinning slot reels and the player/enemy attack animations (e.g., `ReelGameScene.swift`, `PlayerSpriteView.swift`).
* **Repositories**: Data access objects wrapping `SwiftData` containers to manage saving, fetching, and resetting player progress cleanly (e.g., `SavedRunRepository.swift`).

---

## 🚀 Getting Started

### Prerequisites
* **macOS**: Running macOS 14.0 or newer.
* **Xcode**: Version 15.0 or newer (required for the latest SwiftUI and SwiftData APIs).
* **iOS Target**: iOS 17.0+

### Installation & Run
1. Clone this repository to your local machine.
2. Open `Spinora.xcodeproj` (or `Spinora.xcworkspace` if available) in Xcode.
3. Wait for Xcode to resolve any Swift Package dependencies.
4. Select a Simulator (e.g., iPhone 15 Pro) or a connected physical device.
5. Hit the **Run** button (`Cmd + R`) to compile and launch the game.

---

## 📜 Mechanics: The Damage Formula
The damage calculated per turn is dynamic based on your reel combination against the enemy's innate element:

```swift
Total Attack = Base ATK * [ ∑ (Element Count * Weakness Multiplier) ]
```
> *Note: If a player rolls 3 of the same element, the `Element Count` is boosted to `4` as a special combo bonus!*

---

*Enjoy spinning the reels and pushing past your limits in Spinora!*
