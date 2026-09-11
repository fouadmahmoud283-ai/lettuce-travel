# Image credits

## Company assets

| File | Source |
|---|---|
| `logo.jpg` | The company's own logo. Used by `AppLogoMark` (`lib/core/widgets/app_logo_mark.dart`), clipped to a circle. |

## Stock photography

From [Unsplash](https://unsplash.com) under the [Unsplash License](https://unsplash.com/license)
(free for commercial and personal use, no attribution required — credited here anyway as good
practice).

| File | Photo |
|---|---|
| `bus_hero.jpg` | [Yellow school bus on road](https://unsplash.com/photos/sJmp4blGjLU) — Unsplash. **Slated for replacement** with an AI-generated image — see the prompt the team provided. |
| `school_building.jpg` | [School building with modern skyscrapers in background](https://unsplash.com/photos/IY6X1u6kAow) — Unsplash, photographer Tsuyoshi Kozu |

Downloaded via Unsplash's public download endpoint and re-compressed (ImageMagick,
`-resize 1080x -quality ~80`) to keep the app bundle small.

## Pending assets

Referenced in code already (with a graceful fallback if the file is absent), waiting to be
added to this folder:

| File | Used by | Status |
|---|---|---|
| `supervisor_hero.jpg` | `SupervisorHomeScreen` hero header | Not yet added — falls back to the plain gradient with no photo until present |

Any file in this folder can be replaced at any time — the filename is the only contract the
app code relies on; no rebuild step beyond a normal `flutter run`/`flutter build` is needed.
