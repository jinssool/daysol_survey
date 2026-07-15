# DaySol B2C Baseline Survey — Design & Content Spec (v2)

Handoff document for rebuilding this tool as a standalone Vercel-deployed web
app. This supersedes the previous spec: the question set is now finalized
(12 questions), and the flow has been redesigned to feel short despite the
question count. Treat this as the source of truth for content, flow, and
design; rebuild the storage layer as noted in Section 6.

---

## 1. Purpose

A short (~2 minute) consumer survey used in the field (US, in person, on a
phone or tablet) to collect quantitative evidence for a B2B pitch to
Amorepacific / APR / LG생활건강: "we surveyed your consumers directly — here's
what we found, and here's the item that solves it." This is evidence
collection for a pitch deck, not deep qualitative research (that happens in a
separate, longer follow-up interview tool).

Two contexts of use, no auth required:
- **Interviewer, live in the field**: fills out the "Record" tab while
  talking to a consumer.
- **Interviewer, later**: reviews aggregated results in "Stats" and
  individual answers in "Interviewees".

---

## 2. Key UX principle: chunk by phase, not by question

Twelve questions felt long as twelve separate screens. The fix is **not**
fewer questions — it's fewer *screens*. Each of the three phases is rendered
as a single screen containing all of that phase's questions as compact,
one-tap components (pill buttons, Yes/No toggles, rating chips). This mirrors
how the original Screening step (4 questions on one screen) already felt
fast.

**Resulting screen count: 6 total**, regardless of the 12 underlying data
points:

```
0. Interviewee Info      (name)
1. Phase 1 — Who they are     (Q1–Q4, one screen)
2. Phase 2 — Authenticity      (Q5–Q8, one screen)
3. Phase 3 — Willingness to pay (Q9–Q11, one screen)
4. Contact Info                (optional email/IG/LinkedIn)
5. Saved / Follow-us screen    (Q12 lives here, not as a data question)
```

Progress indicator should read **"Phase 1 of 3"** style labels rather than a
12-dot tracker — the phase framing itself makes the survey feel short.

**Auto-advance rule:** within a phase screen, individual sub-questions do
*not* auto-advance the whole screen (multiple questions live on one screen,
so there's nothing to advance to until the interviewer taps the shared
"Next" button at the bottom). What should feel instant is *selecting an
option* — no secondary "confirm" tap, the pill just highlights immediately.
The perceived speed gain comes from screen count (6, not 12), not from
per-question auto-navigation.

---

## 3. Finalized question set

### Phase 1 — Who they are (screen 1, all four questions visible at once)

| Field | Question | Input type | Options |
|---|---|---|---|
| `boughtRecently` | Have you bought a K-beauty product in the last 6 months? | Yes/No pill | Yes / No |
| `channels` | Where do you usually buy K-beauty? | multi-select chips | Amazon / Ulta / Sephora / Brand's own site / Other |
| `brands` | Which brands do you use? | multi-select chips | Sulwhasoo / Laneige / Innisfree / Medicube / AGE-R / Belif / CNP / Other |
| `duration` | How long have you used K-beauty brands? | single-select pill | Less than 6 months / 6 months–1 year / 1–3 years / 3+ years |

`brands` is the field that lets results be segmented per company later
("of respondents who use Laneige, X% said…") — keep this field's values as a
flat array of strings so filtering by brand in Stats is trivial.

If `boughtRecently` = "No", still let them continue (don't hard-block) —
their answers to Phase 2/3 are still useful signal, just flag them in stats
as non-recent-buyers rather than skipping the rest of the survey.

### Phase 2 — Authenticity & verification (screen 2, all four visible at once)

| Field | Question | Input type | Options / notes |
|---|---|---|---|
| `suspectedFake` | Have you ever suspected a product you received was fake? | Yes/No pill | — |
| `trustThirdParty` | Rate your trust in third-party Amazon sellers | 1–5 chip scale | 1 = no trust, 5 = full trust |
| `trustBrandStore` | Rate your trust in the brand's own store | 1–5 chip scale | same scale, shown right next to `trustThirdParty` so the contrast is visible in one glance |
| `knowsVerifyMethod` | Do you know of any way to verify a beauty product is genuine before buying it? | Yes/No pill | if Yes → reveal `verifyMethodDetail` (short textarea): "What method?" |
| `delayedPurchase` | Has uncertainty about authenticity ever made you cancel or delay a purchase? | Yes/No pill | — |

Note: `trustThirdParty` and `trustBrandStore` are two separate 1–5 ratings
(not one relative slider) — render them side by side so the interviewer can
visually compare the two numbers as they're entered. The gap between the two
averages (in Stats) is itself a headline stat: e.g. "brand stores are trusted
1.4 points higher than third-party sellers, on average."

### Phase 3 — Willingness to pay (screen 3, all three visible at once)

| Field | Question | Input type | Options / notes |
|---|---|---|---|
| `pricePreference` | Which matters more to you? | forced binary choice (two large buttons, not pills) | "Lower price, no verification" / "Slightly higher price, guaranteed authenticity" |
| `verifyPricePercent` | If yes, how much of the product price would you pay for it? | single-select pill — **only shown if `pricePreference` = "guaranteed authenticity"** | ~5% / 5–10% / 10–15% / 15–20% / 20%+ |
| `wouldSwitchBrand` | Would you switch to a brand that offered this verification over one that doesn't, even at the same price? | Yes/No pill | — |

### Contact Info (screen 4 — unchanged from previous version)

Same as before: `email`, `instagram`, `linkedin`, all optional, Save button
only requires the interviewee's name from screen 0.

### Closing / Follow-us screen (screen 5 — replaces the old plain "Saved" screen)

This is where **Q12 lives** — it's a scripted closing message plus a
call-to-action, not a data-collection question, so it does not add a
seventh screen of "questions."

Content:
- Same "Saved" heading and thank-you line as before.
- The existing contact-card image (which already contains an Instagram QR
  code) is still shown here.
- New copy block, delivered by the interviewer verbally and shown on screen
  as reinforcement: *"Follow our Instagram and we'll send you a $20 gift.
  We're going to solve this problem — if you care about it, please follow
  along."*
- One optional interviewer-logged field, `willFollow` (Yes/No pill): did the
  person say they'd follow? This is the only new data point from Q12 — log
  it, but don't gate the "Done" button on it.
- "Done — start next interview" button, same behavior as before (resets
  form, returns to screen 0).

---

## 4. Full data model

```json
{
  "id": 1731600000000,
  "intro": { "name": "Maria" },

  "phase1": {
    "boughtRecently": "Yes",
    "channels": ["Amazon", "Ulta"],
    "brands": ["Laneige", "COSRX"],
    "duration": "1–3 years"
  },

  "phase2": {
    "suspectedFake": "No",
    "trustThirdParty": "2",
    "trustBrandStore": "4",
    "knowsVerifyMethod": "No",
    "verifyMethodDetail": "",
    "delayedPurchase": "Yes"
  },

  "phase3": {
    "pricePreference": "Slightly higher price, guaranteed authenticity",
    "verifyPricePercent": "5–10%",
    "wouldSwitchBrand": "Yes"
  },

  "contact": { "email": "", "instagram": "@maria.k", "linkedin": "" },
  "willFollow": "Yes"
}
```

Keep `screeningPassCount`-style derived fields out of the stored object if
they're purely computed from raw answers — recompute them in Stats instead
of storing them redundantly (this avoids the metric definition drifting out
of sync with the raw data over time, which is the main risk when the pass
logic gets refined later).

---

## 5. Stats to compute (drives the pitch deck numbers)

- `suspectedFake` Yes-rate → headline stat ("N% have suspected a fake").
- Mean of `trustThirdParty` vs mean of `trustBrandStore`, and the gap between
  them.
- `knowsVerifyMethod` No-rate → "N% have no way to verify authenticity before
  buying."
- `delayedPurchase` Yes-rate → "N% have had a purchase blocked by
  uncertainty" (this is the closest thing to a revenue-impact number for the
  pitch).
- `pricePreference` split → "N% would pick guaranteed authenticity over a
  lower price."
- `verifyPricePercent` distribution (only among those who chose the
  guaranteed-authenticity side of Q9).
- `wouldSwitchBrand` Yes-rate → brand-switching risk framing.
- All of the above, **filterable by `brands`** — this is what lets you pull
  an Amorepacific-only or LG생활건강-only slice of the data for each pitch.

---

## 6. Design tokens (unchanged)

```js
const ink        = "#1c2321";  // primary text
const paper       = "#f6f4ee";  // page background
const line        = "#d8d3c4";  // borders, dividers
const accent      = "#3d5a4a";  // deep pine green — primary actions, headers
const accentSoft  = "#e4ead2";  // light green — pass-state badges, pill fill
const warn        = "#a5502f";  // rust/terracotta — danger actions, highlight bars

const mono  = `"IBM Plex Mono", ui-monospace, SFMono-Regular, monospace`;
const serif = `"Source Serif 4", Georgia, serif`;
```

Same "field notebook" aesthetic as before: cream background, pine green
accents, monospace for structural/meta text, serif for question copy and
answers. Pill/chip buttons for choices, 12–14px border radius on cards,
1.5px borders in the `line` color. Forced-binary questions (Q9) should use
larger, more visually distinct buttons than the pill-style used elsewhere, to
signal "this one's a real trade-off, think about it" rather than a quick tap.

---

## 7. Data storage (must be rebuilt for Vercel — same guidance as before)

`window.storage` (Claude-artifact-only) must be replaced with a real backend.
Keep the same three function signatures so the rest of the app doesn't need
to change:

```js
saveEntry(entry)       // was window.storage.set(`survey:${id}`, JSON, true)
loadAllEntries()        // was window.storage.list("survey:", true) + get() per key
deleteAllEntries()      // was list + delete() per key
```

Options, in order of least rework:
- **Vercel KV / Upstash Redis** — closest 1:1 mapping to the current
  key/value pattern.
- **Supabase** — one table, `id` (bigint PK) + `payload` (jsonb).
- **Firebase Firestore** — one collection, doc ID = entry id.

No auth or per-user scoping needed — one shared pool of data across all
interviewers, matching current behavior.

---

## 8. Known follow-ups not yet built

- No export/download step before the "delete all" danger-zone action —
  add a "download as CSV/JSON" button before wiring up real deletion.
- The Instagram-follow contact card image is currently a hardcoded base64
  JPEG in the component — on Vercel this should be a normal static asset
  (`/public/contact-card.jpg`).
- `willFollow` is self-reported by the interviewer, not verified — fine for
  a field screener, but don't treat it as a hard conversion number in the
  pitch deck.
- No pagination on the Interviewees list yet — fine at current volumes.
