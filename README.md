# Brief

Brief shows the current Bangkok weather and five Hacker News titles. The last successful briefing stays on screen when a later fetch fails.

## What ContentView may know

`ContentView` creats a `BriefingModel` and keeps it in `@State`. It may read `model.screen` and call `model.load()`.

`screen` is a `WeatherScreen`. The view draws loading, a loaded briefing, or a failed message. `.task` and `.refreshable` both call `load()`.

The view does not name a URL, a JSON key, `BriefingClient`, or `briefing.json`. The client and `BriefingCache` own those.

