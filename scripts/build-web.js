#!/usr/bin/env node
/**
 * Build Web Assets
 * - Minify klarpakke-site.js, calculator.js, klarpakke-ui.js
 * - Generate sourcemaps
 * - Output to web/dist/
 * - No external deps (use native Node)
 */

const fs = require('fs');
const path = require('path');

const SOURCE_DIR = path.join(__dirname, '..', 'web');
const DIST_DIR = path.join(SOURCE_DIR, 'dist');

const FILES_TO_BUILD = [
  'klarpakke-site.js',
  'calculator.js',
  'klarpakke-ui.js',
];

// Simple minification (remove comments + whitespace)
function minifyJs(code) {
  return code
    .replace(/\/\*[\s\S]*?\*\//g, '') // Remove /* */ comments
    .replace(/\/\/.*?$/gm, '') // Remove // comments
    .replace(/^\s+|\s+$/gm, '') // Trim lines
    .replace(/\s+/g, ' ') // Collapse whitespace
    .trim();
}

// Create dist directory
if (!fs.existsSync(DIST_DIR)) {
  fs.mkdirSync(DIST_DIR, { recursive: true });
  console.log(`✓ Created ${DIST_DIR}`);
}

// Build each file
FILES_TO_BUILD.forEach((file) => {
  const sourcePath = path.join(SOURCE_DIR, file);
  const distPath = path.join(DIST_DIR, file);
  const mapPath = path.join(DIST_DIR, `${file}.map`);

  if (!fs.existsSync(sourcePath)) {
    console.warn(`⚠ File not found: ${sourcePath}`);
    return;
  }

  // Read source
  const source = fs.readFileSync(sourcePath, 'utf8');
  const minified = minifyJs(source);

  // Write minified
  fs.writeFileSync(distPath, minified);

  // Write sourcemap (basic)
  const map = {
    version: 3,
    file: file,
    sources: [file],
    mappings: 'A', // Simplified
  };
  fs.writeFileSync(mapPath, JSON.stringify(map, null, 2));

  const sizeBefore = source.length;
  const sizeAfter = minified.length;
  const reduction = Math.round(((sizeBefore - sizeAfter) / sizeBefore) * 100);

  console.log(
    `✓ ${file} | ${sizeBefore}B → ${sizeAfter}B (${reduction}% reduction)`
  );
});

console.log(`\n✓ Build complete: ${DIST_DIR}`);
