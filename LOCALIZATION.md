# Localization Guide

## Supported Languages

The app supports the following languages:
- **en** — English (US) - Default
- **es** — Spanish
- **nl** — Dutch
- **de** — German
- **fr** — French
- **en-GB** — English (UK)
- **ar** — Arabic (RTL supported)

## How Localization Works

### UI Strings (Buttons, Labels)
- All UI strings are in `Localizable.strings`
- Xcode will need to be configured to add localized versions
- SwiftUI automatically uses the correct language based on device settings

### JSON Content (Itineraries)
The app uses language-specific JSON files with automatic fallback:

**File naming convention:**
- `itin_plaza.json` — English (default)
- `itin_plaza_es.json` — Spanish
- `itin_plaza_nl.json` — Dutch
- `itin_plaza_de.json` — German
- `itin_plaza_fr.json` — French
- `itin_plaza_ar.json` — Arabic

**Fallback behavior:**
If a language-specific file doesn't exist, the app loads the English version.

## What Gets Localized

### JSON Files - Localize These Fields:
- `short_description`
- `long_description`
- `opening_hours` (translate day names and format times per locale)
- `notes`

### JSON Files - DO NOT Localize:
- `itinerary_name` — Keep business/place names in original
- `name` — Business names stay as-is
- `formatted_address` — Addresses in original format
- `phone` — Keep original format
- `website` — URLs unchanged
- `place_id`, `lat`, `lng`, `icon_category` — Technical fields

## Translation Workflow

### 1. Translating UI Strings

In Xcode:
1. Select `Localizable.strings` in Project Navigator
2. Open File Inspector (⌥⌘1)
3. Click "Localize..." button
4. Add languages: Spanish, Dutch, German, French, Arabic
5. Xcode creates separate `.strings` files for each language
6. Translate the strings in each file

### 2. Translating JSON Itineraries

For each itinerary (e.g., `itin_plaza.json`):

1. **Copy the English file:**
   ```bash
   cp itin_plaza.json itin_plaza_es.json
   ```

2. **Open the new file and translate only:**
   - `short_description`
   - `long_description`
   - `opening_hours` (day names and time format)
   - `notes`

3. **Example:**
   ```json
   {
     "itinerary_name": "Country Club Plaza",  // ← Keep original
     "short_description": "Compras, cultura y arte...",  // ← Translate
     "long_description": "El Country Club Plaza...",  // ← Translate
     "locations": [
       {
         "name": "The Nelson-Atkins Museum",  // ← Keep original
         "formatted_address": "4525 Oak St...",  // ← Keep original
         "phone": "(816) 751-1278",  // ← Keep original
         "website": "https://...",  // ← Keep original
         "opening_hours": [  // ← Translate
           "Lunes: 10:00 – 17:00",
           "Martes: Cerrado",
           ...
         ],
         "notes": "Entrada gratuita los jueves"  // ← Translate
       }
     ]
   }
   ```

### 3. Testing Translations

**In iOS Simulator:**
1. Open Settings app
2. Go to General → Language & Region
3. Add a language (e.g., Spanish)
4. Set it as primary
5. Relaunch the app

**In Xcode:**
1. Edit Scheme (⌘<)
2. Run → Options → App Language
3. Select language to test
4. Run the app

## Arabic (RTL) Considerations

SwiftUI automatically handles right-to-left layout for Arabic:
- Text aligns right
- UI elements mirror (back buttons flip, etc.)
- No code changes needed

**Just ensure:**
- Numbers and times read correctly in Arabic
- Test the layout in Arabic to verify spacing

## Adding New Languages

1. Add to `ItineraryLoader.currentLanguage` logic if needed
2. Create localized `Localizable.strings` in Xcode
3. Create `itin_*_XX.json` files for each itinerary
4. Update language picker (future landing screen)

## Language Override (Future)

When the language picker is implemented, it will:
1. Store user preference in `UserDefaults`
2. Override `ItineraryLoader.currentLanguage`
3. Reload map with new language files
4. UI automatically updates via `Localizable.strings`

## Questions?

- Device language changes are automatic
- Missing translations fall back to English
- Bundle size: ~5KB per itinerary × 7 languages = ~35KB per location (negligible)
