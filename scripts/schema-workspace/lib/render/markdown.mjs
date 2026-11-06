import path from "node:path/posix";

const NEEDS_QUOTES = /[:#{}\[\],&*?|<>=!%@`'"\\]|^\s|\s$|^(true|false|null|yes|no|~)$|^[-\d.]/i;

export function yamlScalar(value) {
  if (value === null || value === undefined) return "null";
  if (typeof value === "boolean" || typeof value === "number") return String(value);
  const text = String(value);
  if (text === "" || NEEDS_QUOTES.test(text)) return JSON.stringify(text);
  return text;
}

function yamlValue(value) {
  if (Array.isArray(value)) return `[${value.map(yamlScalar).join(", ")}]`;
  if (value && typeof value === "object") {
    return `{ ${Object.entries(value)
      .map(([key, item]) => `${key}: ${yamlValue(item)}`)
      .join(", ")} }`;
  }
  return yamlScalar(value);
}

/** Renders flat YAML frontmatter; arrays and objects use flow style so pages stay greppable. */
export function frontmatter(fields) {
  const lines = Object.entries(fields)
    .filter(([, value]) => value !== undefined)
    .map(([key, value]) => `${key}: ${yamlValue(value)}`);
  return `---\n${lines.join("\n")}\n---\n`;
}

export function cell(value) {
  if (value === null || value === undefined || value === "") return "—";
  return String(value).replaceAll("|", "\\|").replaceAll(/\r?\n/g, " ");
}

export function code(value) {
  if (value === null || value === undefined || value === "") return "—";
  return `\`${String(value).replaceAll("`", "'").replaceAll("|", "\\|").replaceAll(/\r?\n/g, " ")}\``;
}

export function table(headers, rows) {
  if (rows.length === 0) return "_None._\n";
  const align = headers.map((header) => (header.startsWith("#") ? "---:" : "---"));
  return [`| ${headers.join(" | ")} |`, `| ${align.join(" | ")} |`, ...rows.map((row) => `| ${row.map(cell).join(" | ")} |`), ""].join("\n");
}

export function link(label, fromPage, toPage, anchor = "") {
  const relativePath = path.relative(path.dirname(fromPage), toPage) || path.basename(toPage);
  return `[${label}](${relativePath}${anchor ? `#${anchor}` : ""})`;
}

export function curated(entry, body) {
  const text = String(body ?? "").trim();
  if (!text) return "";
  const stamp = `${entry.provenance ?? "model_assisted"}, ${entry.reviewed ?? "unreviewed"}`;
  return `> curated (${stamp}) — ${text.split(/\r?\n/).join("\n> ")}\n`;
}

export function heading(level, text) {
  return `${"#".repeat(level)} ${text}\n`;
}

export function joinBlocks(blocks) {
  return `${blocks
    .filter((block) => block && block.trim())
    .map((block) => block.trimEnd())
    .join("\n\n")}\n`;
}

export function anchorOf(text) {
  return text.toLowerCase().replaceAll(/[^a-z0-9\s-]/g, "").trim().replaceAll(/\s+/g, "-");
}

export function truncate(text, maxLength) {
  const flat = String(text ?? "").replaceAll(/\s+/g, " ").trim();
  return flat.length <= maxLength ? flat : `${flat.slice(0, maxLength - 1)}…`;
}
