# InariSense — Design System Proposal

## Design Principles

1. **Nature-inspired, not literal.** No generic leaf clipart, no stock "green app" clichés. The palette and shapes should evoke soil, growth, and weather without illustrating a lead on every screen.
2. **Confidence and uncertainty are visually distinct.** High/moderate/low confidence, and early/ideal/late/unsuitable planting windows, need to be instantly scannable — color alone is not enough (per the accessibility requirement that status never relies on color alone).
3. **Calm, not cluttered.** A beginner gardener should never feel like the app is showing them a spreadsheet. Generous whitespace, one primary action per screen.
4. **Data provenance is visible, not hidden.** Wherever a recommendation or identification result appears, there is always room in the layout for "why" and "source" — these are never an afterthought tucked into a tooltip.

## Color Palette

Names for what they evoke, not literal color names, so the palette can be retuned without renaming every reference in code.

| Token     | Approx. Hex | Use                                              |
| --------- | ----------- | ------------------------------------------------ |
| `soil`    | #3D2B1F     | Primary text, high-contrast elements             |
| `canopy`  | #2F5233     | Primary brand color, main buttons                |
| `sprout`  | #7FB069     | Secondary accent, success states                 |
| `bloom`   | #E08E45     | Warm accent — warnings, "early" status           |
| `frost`   | #A8C5D6     | Cool accent — "unsuitable"/cold-related status   |
| `harvest` | #C9A227     | "Late" status, harvest-related states            |
| `paper`   | #FAF7F2     | App background (warm off-white, not stark white) |
| `stone`   | #D3C7B4     | Card backgrounds, dividers                       |
| `ink`     | #1A1A1A     | Body text                                        |
| `error`   | #B3261E     | Errors, destructive actions                      |

Status-color mapping (never color-alone — always paired with an icon or label per the accessibility requirement):

- **Ideal** -> `sprout` + checkmark icon
- **Early** -> `bloom` + clock icon
- **Late** -> `harvest` + hourglass icon
- **Unsuitable** -> `frost` + warning icon
- **Insufficient data** -> `stone` (neutral) + question-mark icon

Confidence levels (identification and recommendations):

- **High** -> solid `canopy` fill
- **Low** -> `canopy` outline only, not filled
- **None** -> `stone` outline, dashed

## Typography

- **Headings:** a humanist sans-serif with some warnth (e.g. Nunito or Work Sans) — friendly, not corporate.
- **Body text:** a highly legible sans-serif optimized for small sizes (e.g. Inter or system default) — readability over personality for dense recommendation cards.
- **Scale:**
  - Display (screen titles): 28sp
  - Heading (section titles): 20sp
  - Body: 16sp
  - Caption/meta (sources, timestamps): 13sp
- Never below 13sp anywhere — ties to the dynamic-text-sizing accessibility requirement; the whole scale needs to survive the user bumping system font size up without braking layouts.

## Spacing Scale

4px base unit: 4 / 8 / 12 / 16 / 24 / 32 / 48. Card padding defualts to 16px; section gaps default to 24px.

## Iconography

Outline-style icons (not filled/glyph-heavy), consistent stroke width.  
Avoid literal lead icons for navigation — use shape/action metaphors instead (e.g. a calendar glyph for the planting calendar, a camera outline for identification, a simple grid for garden inventory).

## Component Direction

- **Cards:** rounded corners (12px radius), `stone` background, subtle shadow — used for every recommendation, identification candidate, and task item, so the visual langauage is consistent everywhere structured data appears.
- **Status chips:** small pill-shaped badges combining color + icon + short label (e.g. "● Ideal"), used consistently across planting windows, identification confidence, and task priority.
- **Primary buttons:** filled `canopy`, rounded (24px radius, pill-like).
- **Secondary/text buttons:** `canopy` text, no fill.

## Screen Inventory (current + planned)

| Screen                     | Status                                                 |
| -------------------------- | ------------------------------------------------------ |
| Home dashboard             | Not built                                              |
| Location Setup             | Built (KAN-13) — needs visual pass against this system |
| Identify (camera capture)  | Not built                                              |
| Identification results     | Not built                                              |
| My Garden (inventory list) | Not built                                              |
| Garden detail              | Not built                                              |
| Planting Calendar          | Not built (KAN-21, next)                               |
| Tasks dashboard            | Not built                                              |
| Journal                    | Not built                                              |
| Learn                      | Not built                                              |

## Applying This Retroactively

`LocationSetupScreen` (KAN-13) was built before this system existed and
currently uses Flutter's default Material styling. It should get a
follow-up visual pass once the Flutter theme implementation (next step)
exists, rather than rushing a mismatched retrofit right now.
