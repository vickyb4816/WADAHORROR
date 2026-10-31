---
name: Tatya Vinchu Wada Horror
colors:
  surface: '#151317'
  surface-dim: '#151317'
  surface-bright: '#3b383d'
  surface-container-lowest: '#0f0d11'
  surface-container-low: '#1d1b1f'
  surface-container: '#211f23'
  surface-container-high: '#2c292d'
  surface-container-highest: '#373438'
  on-surface: '#e7e1e6'
  on-surface-variant: '#e6bdbc'
  inverse-surface: '#e7e1e6'
  inverse-on-surface: '#322f34'
  outline: '#ac8888'
  outline-variant: '#5c3f3f'
  surface-tint: '#ffb3b3'
  primary: '#ffb3b3'
  on-primary: '#680015'
  primary-container: '#dc143c'
  on-primary-container: '#fff1f0'
  inverse-primary: '#bf0030'
  secondary: '#f2be71'
  on-secondary: '#442b00'
  secondary-container: '#684400'
  on-secondary-container: '#e6b367'
  tertiary: '#b0c9e4'
  on-tertiary: '#193248'
  tertiary-container: '#5a728a'
  on-tertiary-container: '#eef5ff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdad9'
  primary-fixed-dim: '#ffb3b3'
  on-primary-fixed: '#40000a'
  on-primary-fixed-variant: '#920022'
  secondary-fixed: '#ffddb1'
  secondary-fixed-dim: '#f2be71'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#614000'
  tertiary-fixed: '#cee5ff'
  tertiary-fixed-dim: '#b0c9e4'
  on-tertiary-fixed: '#011d32'
  on-tertiary-fixed-variant: '#31495f'
  background: '#151317'
  on-background: '#e7e1e6'
  surface-variant: '#373438'
typography:
  headline-xl:
    fontFamily: Noto Serif
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Noto Serif
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: 0.01em
  headline-lg-mobile:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: 0.01em
  headline-md:
    fontFamily: Noto Serif
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.08em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.06em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-mobile: 0.75rem
  margin: 2.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system delivers an oppressive, cinematic, psychological horror experience rooted deeply in classical Maharashtrian architectural folklore and dark occult mythology. Centered on the malevolent legend of the cursed ventriloquist puppet trapped within an expansive, crumbling 18th-century Peshwa-era mansion (*Wada*), the aesthetic merges antique cultural relic textures with immediate, nerve-wracking terror.

The visual direction combines **Tactile / Skeuomorphic Antiquity** with **High-Contrast Dark Horror HUD**:
- **Tactile Relics:** Surfaces evoke cold basalt stone masonry (*Khadki Dagad*), dark teak wood carvings (*Sagwan*), weathered manuscript parchment, and tarnished oil lamp brass (*Pital*).
- **Demonic Incarnation:** Abrupt, high-intensity blood-crimson flares mimic the cursed puppet’s glowing red eyes and pulsating occult energy, piercing through oppressive shadows.
- **Folklore Tension:** Devanagari calligraphy motifs and architectural silhouettes (arched courtyards, jali screens, tulsi vrindavan outlines) structure the frame, giving players an authentic sense of claustrophobia within rural Konkan and Desh lore.
- **Accessibility in Darkness:** Deep shadows are strictly calibrated against high-legibility typographic tokens and luminous interactive focal points, preventing eye strain in low-light gameplay environments.

## Colors

The color palette establishes an uncompromising psychological horror atmosphere, balancing pitch midnight gloom with antique cultural warmth and visceral supernatural threat.

- **Primary (`#DC143C` - Rakta Crimson):** The signature demonic glow reflecting Tatya Vinchu’s possessed red pupils and lethal occult danger. Reserved strictly for lethal alerts, high-threat meters, critical health states, active curses, and primary aggressive gameplay actions.
- **Secondary (`#D4A359` - Samai Antique Brass):** The warm, flickering illumination of brass oil lamps (*samai/diya*) and aged parchment. Used for vital wayfinding, active interactive points, journal manuscripts, and primary actionable UI elements.
- **Tertiary (`#5A728A` - Chandani Moonlit Slate):** Cold Konkan midnight moonlight piercing through barred teak windows and central courtyards. Governs neutral feedback, inventory secondary states, defensive counters, and inactive slot frames.
- **Neutral (`#0F0D11` - Kalokh Basalt Void):** Ultra-deep charcoal obsidian with purple-brown undertones, drawn from wet monsoon stone and decaying teak woodwork. Forms the core canvas, HUD panels, modal backdrops, and environmental scrims.

### Semantic Tones & Surface Behavior
- **Surface Dark (`#0A080C`):** Base canvas and letterboxing.
- **Surface Elevation (`#16131A`):** Modal drawers, spatial map blueprints, item inspection viewports.
- **Borders & Inlays (`#362C24`):** Tarnished iron and aged dark timber filigree.
- **Text Primary (`#EADCC6`):** Hand-pounded parchment white; ensures 12:1+ contrast against the basalt canvas.
- **Text Muted (`#8E7E70`):** Aged ash gray for lore footnotes and non-urgent status indicators.

## Typography

The typographic hierarchy bridges historical literary tradition with tactical gameplay readability:

- **Headlines (`Noto Serif`):** Selected for its profound, chisel-carved authority and natural harmony with Devanagari script structures. It conveys classical mystery, ancient scripture, and dramatic psychological doom.
- **Narrative & Body (`Plus Jakarta Sans`):** Clean, warm humanist curves ensure that long diary entries, found letters, and dialogue logs remain strain-free across dim display setups.
- **Technical HUD & Labels (`Space Grotesk`):** Geometric, precise, and subtly mechanical to balance puppet horror with tactile operational feedback (inventory weight, map coordinates, sanity counters, compass bearings).

### Usage Rules
- All major chapter headings and demonic incantations must leverage uppercase tracking in `headline-lg` or `Noto Serif` with slight brass or crimson drop glow.
- When rendering Devanagari script elements (e.g., *ओम भग भुगे भगनी भागोदरी...*), line-height is automatically expanded by +20% to honor Matra lines and ascender marks without clipping.

## Layout & Spacing

The layout philosophy uses a **Diegetic Architectural Grid** structured to emulate the symmetric yet suffocating corridors and courtyards of a traditional Maharashtrian Wada.

- **Desktop (HUD & Exploration Screens):** 12-column symmetrical layout anchored along peripheral screen boundaries to preserve unobstructed vision of dark corridors. The central 6 columns are reserved for player line-of-sight and direct environmental investigation.
- **Tablet / Split Screen:** 8-column layout with collapsible inventory pouches and map legend draw-outs.
- **Mobile / Tactical Companion:** 4-column columnated stack prioritizing thumb-friendly panic buttons (flashlight toggle, warding charms) at the bottom 25% of the screen height.
- **Rhythm:** Spacing follows strict structural cadences where nested item grids use `space-sm` (8px) for tightly packed inventory pouches, while narrative journal entries breathe with `space-lg` (24px) margins.

## Elevation & Depth

Visual depth is achieved through **Tonal Occult Layering and Ambient Lamplight Diffusion**:

1. **Base Layer (Level 0):** The living nightmare viewport. Cold basalt stone, dynamic volumetric shadows, and moonlight.
2. **Diegetic Layer (Level 1):** In-world UI elements (doors, interactive locked trunks, Tulsi Vrindavan shrines). Surrounded by a low-intensity, directional brass glow (`box-shadow: 0 0 16px rgba(212, 163, 89, 0.25)`).
3. **Tactical Overlay (Level 2):** Blueprint architectural maps, pouch grids, inventory compartments. Uses solid slate-basalt (`#16131A`) backdrops, enclosed by hairline 1px tarnished brass outlines with a 45% opacity vignette.
4. **Demonic Intervention (Level 3):** Tatya Vinchu presence indicators, sanity collapse, jump-scare proximity. Defined by pulsating crimson rim glows (`box-shadow: 0 0 32px rgba(220, 20, 60, 0.45)`), accompanied by subtle screen-edge chromatic aberration.
5. **Modal & Pause Dialogs (Level 4):** Frosted smoky-glass overlays (`backdrop-filter: blur(12px)`) tinted with 85% opacity `#0A080C`.

## Shapes

To mirror the heavy stone lintels, iron-studded timber doors, and sharp brass corners of 18th-century Wada architecture, the system relies on a **Soft, Angular Profile** (`roundedness: 1`):

- **Core Elements:** Modest 4px radius (`rounded`) across cards, action buttons, inventory tiles, and map markers, preventing the interface from feeling bubbly or casual.
- **Notched Inlays:** Critical lore containers and ritual seals feature 45-degree corner notches reminiscent of hand-chiseled masonry.
- **Parchment & Paper Fragments:** Irregular, weathered deckle-edge simulation on inspectable journal pages and torn maps.

## Components

### Buttons & Interactive Controls
- **Primary Danger / Ritual Action:** Deep crimson core (`#DC143C`) fading into pitch-black gradients, bordered by 1px solid brass with an outer sinister blood pulse on hover/focus. Typography in `Space Grotesk` uppercase.
- **Secondary / Investigation Button:** Antique brass frame (`#D4A359`) with transparent basalt interior. Fills with subtle warm amber lamplight upon cursor contact.
- **Inactive / Cursed Action:** Weathered ash border with strike-through Devanagari script indicator.

### Inventory Slots & Item Cards
- Square frames with dark slate-teak interiors (`#16131A`) encased in 1px weathered stone borders (`#362C24`).
- Equipped items cast a faint amber brass aura; possessed or cursed items (e.g., puppet strings, cracked glass eyes) emit a faint, persistent Rakta Crimson haze with subtle screen grain.
- Item count badges reside at bottom-right in bold `label-sm`.

### Blueprint Architectural Map HUD
- Weathered parchment overlay with deep umber floorplan outlines depicting the Wada’s chambers (Puja Room, Central Courtyard, Secret Underground Cellar).
- Player locator: Sharp red arrow with directional vision cone.
- Danger events: Flickering crimson 'X' markers that distort when Tatya Vinchu enters adjacent corridors.

### Sanity & Puppet Proximity Meters
- Structured as dual horizontal filigree tubes.
- The Sanity bar recedes from tranquil moonlit blue (`#5A728A`) to trembling pitch ash.
- The Tatya Vinchu Proximity gauge fills with jagged, glowing crimson bars as malicious doll laughter and footsteps amplify.

### Dialogue & Lore Inscriptions
- Centered at the lower third of the canvas with a 90% obsidian gradient scrim.
- Speaker names rendered in `Noto Serif` brass text, accompanied by speaker portraits framed in carved wooden relief borders.