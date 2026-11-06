/** Parses a Postgres array literal (`{a,"b c"}`) when the driver hands it back as text. */
export function pgArray(value) {
  if (value === null || value === undefined) return [];
  if (Array.isArray(value)) return value;
  const body = String(value).trim();
  if (!body.startsWith("{") || !body.endsWith("}")) return [body];
  const inner = body.slice(1, -1);
  if (inner === "") return [];
  const items = [];
  let current = "";
  let quoted = false;
  for (let index = 0; index < inner.length; index += 1) {
    const char = inner[index];
    if (quoted) {
      if (char === "\\") {
        current += inner[index + 1];
        index += 1;
      } else if (char === '"') quoted = false;
      else current += char;
    } else if (char === '"') quoted = true;
    else if (char === ",") {
      items.push(current);
      current = "";
    } else current += char;
  }
  items.push(current);
  return items;
}

export function rowCountClass(reltuples) {
  if (reltuples === null || reltuples === undefined || reltuples < 0) return "unknown";
  if (reltuples === 0) return "none";
  if (reltuples < 1_000) return "small";
  if (reltuples < 1_000_000) return "medium";
  return "large";
}
