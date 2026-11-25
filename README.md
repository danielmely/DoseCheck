# DoseCheck

iOS app (SwiftUI, iOS 17+) that answers "how much of this is too much?" Search a substance, enter your body weight, and see everyday guidance limits, toxic thresholds and rough lethal estimates in familiar units (cups of coffee, teaspoons of salt).

## Design rules

- Safety framing first: first-launch disclaimer, plus Poison Control (1-800-222-1222) and 988 shown on every screen.
- Medications show label guidance only. No toxic or lethal numbers.
- Every figure is an estimate. Entries carry `verified` and `sources` fields; the UI flags anything unverified.
- Substances with no established human lethal dose say so instead of showing an animal number as fact.

## Run it

```
brew install xcodegen
xcodegen generate
open DoseCheck.xcodeproj
```

Or create a blank iOS App project in Xcode and drag in the `DoseCheck/` folder.

Bundle ID is `com.danielmely.dosecheck`; change it in `project.yml`.

## Data

`DoseCheck/Resources/substances.json`. The starter set has 7 entries. 6 are checked against their sources (FDA, NIH/PMC, SDS, product labels, AHA); **alcohol is still unverified** (its lethal figure needs a primary source). The app flags any entry with `"verified": false`.

## App Store notes

Expect review scrutiny (Guideline 1.4, physical harm). Keep the safety framing, avoid any "method" language, and keep medications and known self-harm agents out of lethal-dose display.
