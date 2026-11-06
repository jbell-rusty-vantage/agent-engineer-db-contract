/**
 * Best-effort, mechanical extraction from PL/pgSQL / SQL function bodies: raised messages,
 * relations read/written, functions called. Results are marked `best_effort` in the IR.
 */

const RAISE_CLAUSE = /raise\s+exception\b([^;]*);/gi;
const MESSAGE_ASSIGNMENT = /message\s*=\s*'((?:[^']|'')*)'/i;
const FIRST_LITERAL = /'((?:[^']|'')*)'/;
const WRITE_STATEMENT = /\b(insert\s+into|update|delete\s+from|truncate(?:\s+table)?)\s+([a-z_][a-z0-9_]*)\.([a-z_][a-z0-9_]*)/gi;

export function extractRaises(body) {
  const messages = new Set();
  for (const match of body.matchAll(RAISE_CLAUSE)) {
    const clause = match[1];
    const literal = clause.match(MESSAGE_ASSIGNMENT)?.[1] ?? clause.match(FIRST_LITERAL)?.[1];
    if (literal) messages.add(literal.replaceAll("''", "'"));
  }
  return [...messages].sort();
}

function qualifiedMentions(body, qualifiedNames) {
  const lowered = body.toLowerCase();
  return qualifiedNames.filter((name) => new RegExp(`\\b${name.replaceAll(".", "\\.")}\\b`).test(lowered));
}

/**
 * @param {string} body
 * @param {{relationNames: string[], functionNames: string[]}} known qualified names present in the IR
 */
export function extractTouches(body, known) {
  const writes = new Set();
  for (const match of body.matchAll(WRITE_STATEMENT)) {
    const qualified = `${match[2]}.${match[3]}`.toLowerCase();
    if (known.relationNames.includes(qualified)) writes.add(qualified);
  }
  const mentioned = qualifiedMentions(body, known.relationNames);
  const reads = mentioned.filter((name) => !writes.has(name));
  const calls = qualifiedMentions(body, known.functionNames).filter((name) =>
    new RegExp(`\\b${name.replaceAll(".", "\\.")}\\s*\\(`).test(body.toLowerCase()),
  );
  return { reads: reads.sort(), writes: [...writes].sort(), calls: calls.sort() };
}

const TYPE_LEADING_WORDS = new Set(["timestamp", "time", "double", "character", "bit", "interval", "setof"]);

function splitTopLevel(text, separator) {
  const parts = [];
  let depth = 0;
  let quoted = false;
  let current = "";
  for (const char of text) {
    if (char === "'") quoted = !quoted;
    if (!quoted) {
      if (char === "(" || char === "[") depth += 1;
      if (char === ")" || char === "]") depth -= 1;
      if (char === separator && depth === 0) {
        parts.push(current.trim());
        current = "";
        continue;
      }
    }
    current += char;
  }
  if (current.trim()) parts.push(current.trim());
  return parts;
}

/** Parses `pg_get_function_arguments` output into `{ mode, name, type, default }` entries. */
export function parseArguments(argumentText) {
  if (!argumentText.trim()) return [];
  return splitTopLevel(argumentText, ",").map((part) => {
    const [declaration, defaultExpression] = part.split(/\s+DEFAULT\s+/i);
    let tokens = declaration.trim().split(/\s+/);
    let mode = "in";
    if (/^(IN|OUT|INOUT|VARIADIC)$/i.test(tokens[0])) {
      mode = tokens[0].toLowerCase();
      tokens = tokens.slice(1);
    }
    const hasName = tokens.length >= 2 && !TYPE_LEADING_WORDS.has(tokens[0].toLowerCase()) && !tokens[0].includes("[");
    const name = hasName ? tokens[0] : null;
    const type = (hasName ? tokens.slice(1) : tokens).join(" ");
    return { mode, name, type, default: defaultExpression?.trim() ?? null };
  });
}
