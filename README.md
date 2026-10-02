# Daily Breakthrough

A small iPhone app plus a home screen widget. The widget shows today's passage (text and credit) with no notification and no tapping. It refreshes once a day.

Needs Xcode 16 or newer, iOS 18 or newer on the phone, and a free Apple ID.

## How it works

- `feed.json` in this repo holds today's passage: `date`, `excerpt`, `credit`, `source`.
- The app and the widget fetch `FEED_URL` (set in `Config/Settings.xcconfig`).
- Every successful fetch is cached in an App Group shared container. If a fetch fails, both show the last cached passage.
- To change the passage, commit a new `feed.json`. The widget picks it up shortly after midnight local time (iOS decides the exact moment) and whenever you open the app.

## Feed URL (read this first)

`raw.githubusercontent.com` does not serve files from a private repo without a token. Pick one:

1. Make the repo public (the passages are public domain), or
2. Host `feed.json` on your own server and set `FEED_URL` to that URL (must be https).

## Setup

1. Clone: `git clone https://github.com/ethanmlam/daily-breakthrough.git`
2. Open `DailyBreakthrough.xcodeproj` in Xcode.
3. Open `Config/Settings.xcconfig` and set:
   - `APP_BUNDLE_ID` to something unique, like `com.ethanlam.dailybreakthrough`
   - `APP_GROUP_ID` to `group.` plus the same string, like `group.com.ethanlam.dailybreakthrough`
   - `FEED_URL` if you are not using the public repo
4. Plug in your iPhone, turn on Developer Mode (Settings > Privacy & Security > Developer Mode), and trust the Mac.
5. In Xcode, click the project at the top of the file list. For both targets (`DailyBreakthrough` and `DailyWidget`), go to Signing & Capabilities, tick "Automatically manage signing", and pick your Personal Team (your Apple ID; add it under Xcode > Settings > Accounts if it is missing).
6. App Group: the entitlement is already in the project. With automatic signing, Xcode registers the group for you. If Xcode shows an App Groups error, open Signing & Capabilities on each target, find App Groups, and make sure the group matches `APP_GROUP_ID`.
7. Pick your iPhone as the run destination and press Run. Open the app once so it loads and caches today's passage.
8. On the iPhone home screen, long-press empty space, tap the + button, search "Daily Breakthrough", and add the medium or large widget.

## The 7-day catch

With a free Apple ID, Apple expires the app after 7 days. The widget goes blank until you plug in, open the project in Xcode, and press Run again. A paid developer account ($99/year) makes the signing last a year and is required for the App Store.

## Files

- `App/` SwiftUI app
- `Widget/` WidgetKit extension
- `Shared/` passage model, fetch, and cache used by both
- `Config/` settings, plists, entitlements
- `feed.json` the daily passage
