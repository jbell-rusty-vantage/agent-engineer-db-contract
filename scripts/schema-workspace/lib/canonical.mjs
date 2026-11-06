import { createHash } from "node:crypto";

/** Sorted-key deep copy; arrays keep their order (callers sort before canonicalizing). */
export function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .filter((key) => value[key] !== undefined)
        .map((key) => [key, canonical(value[key])]),
    );
  }
  return value;
}

/** RFC 8785-style canonical JSON: sorted keys, no whitespace, LF-free. */
export function canonicalJson(value) {
  return JSON.stringify(canonical(value));
}

/** Pretty canonical JSON for committed files (sorted keys, two-space indent, trailing LF). */
export function prettyJson(value) {
  return `${JSON.stringify(canonical(value), null, 2)}\n`;
}

export function sha256Hex(input) {
  return createHash("sha256").update(input).digest("hex");
}

export function digest(value) {
  return `sha256:${sha256Hex(canonicalJson(value))}`;
}

export function digestText(text) {
  return `sha256:${sha256Hex(text)}`;
}

export function byteLength(text) {
  return Buffer.byteLength(text, "utf8");
}

export function compareStrings(a, b) {
  return a < b ? -1 : a > b ? 1 : 0;
}

export function sortBy(items, keyOf) {
  return [...items].sort((a, b) => compareStrings(keyOf(a), keyOf(b)));
}
