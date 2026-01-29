# Webflow Designer Extension: Klarpakke

Webflow Designer extension som oppretter og verifiserer Klarpakke pages + element IDs.

## Features

- **Create Pages**: Idempotent creation of 7 core pages (index, pricing, /app/*, login, signup)
- **Verify IDs**: Check that all required element IDs exist on each page
- **Status Panel**: Real-time feedback on creation/verification progress

## Development

```bash
cd webflow-designer-extension
npm install
npm run dev
```

Then install in Webflow Designer:
1. Dashboard → Custom Apps
2. Use local dev server: http://localhost:8080

## Build for Release

```bash
npm run build
```

Output: `dist/klarpakke-designer.js`

## Installation in Webflow

1. Get the Webflow App SDK from https://developers.webflow.com/designer-extensions
2. Register extension with your app
3. Users can then install from Webflow Dashboard → Custom Apps → Klarpakke

## Abilities Required

- `createPage`: Create new pages
- `listPages`: List existing pages
- `updateElement`: Add/update element properties (future)
- `getPageElements`: Read element structure

See [Webflow Designer API docs](https://developers.webflow.com/designer-extensions/reference).
