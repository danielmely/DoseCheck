# DoseCheck

iOS app (SwiftUI, iOS 17+) that answers "how much of this is too much?" Search a substance, enter your body weight, and see everyday guidance limits, toxic thresholds and rough lethal estimates in familiar units (cups of coffee, teaspoons of salt).

## Features

- Saved people (top-left button): name, gender at birth, height, weight, and lb or kg preference. Several people can be saved and one is active. Stored on the device only.
- Every edible shows three answers: safe daily intake, toxicity reported, and fatal dose. If there is no reliable number, the row says why.
- Weight scales toxic and fatal doses, gender at birth selects sex-specific guidance (sugar, alcohol), and height + weight + gender at birth estimate body water (Hume-Weyers) for the blood alcohol estimate.
- Pinned call buttons for Poison Control and the 988 lifeline on every screen.

- Home screen is a single search bar ("Advil, Calories, Sugar, etc.") with a Browse button that lists everything in the app by category.

## Design rules

- Safety framing first: first-launch disclaimer, plus Poison Control (1-800-222-1222) and 988 shown on every screen.
- Medications show label guidance only. No toxic or lethal numbers.
- Every figure is an estimate. Entries carry `verified`, `sources` and (where it applies) `guidanceMgPerKg` and `measuredAs` fields; the UI flags anything unverified.
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

`DoseCheck/Resources/catalog.json` lists about 140 names for Browse (foods, drinks, supplements, medications, household products, poisonous plants) that have no figures yet; they show "Coming soon". `DoseCheck/Resources/substances.json` holds the entries with real figures. To promote a catalog item, add a full entry to substances.json and remove it from catalog.json. There are 1406 entries: caffeine drinks and chocolates (FDA, Mayo Clinic), sweeteners (FDA acceptable daily intakes), vitamins and minerals (National Academies upper intake levels), salts, OTC medications (Drug Facts labels, label limits only), nicotine (a 2014 toxicology review), herbal supplements (EFSA, NIH, FDA), poisonous plants and household products (Poison Control, CDC, MedlinePlus; warnings and symptoms only, no dose numbers). Alcohol now shows a sourced toxic dose and qualitative fatal note (no unsourced fatal figure), and 18 alcoholic drinks use the NIAAA/CDC standard drink sizes. Every entry stores its sources as `{title, url}`; the yellow Sources button in the footer lists them all. The app flags any entry with `"verified": false`.

## App Store notes

Expect review scrutiny (Guideline 1.4, physical harm). Keep the safety framing, avoid any "method" language, and keep medications and known self-harm agents out of lethal-dose display.
