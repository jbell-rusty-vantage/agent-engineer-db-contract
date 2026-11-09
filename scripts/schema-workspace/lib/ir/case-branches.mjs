/**
 * Splits a PL/pgSQL dispatcher body (`case op when '<operation>' then … end case`) into its arms.
 * Mechanical and best effort, like the rest of the function-body scan.
 */

const BLOCK_OPENERS = new Set(["begin", "case", "if", "loop"]);
const IDENTIFIER_START = /[a-z_]/i;
const IDENTIFIER_PART = /[a-z0-9_$]/i;

/** Minimal PL/pgSQL scanner: words, string literals, and single-character punctuation with source offsets. Comments are dropped. */
export function tokenizeBody(body) {
  const tokens = [];
  let index = 0;
  while (index < body.length) {
    const char = body[index];
    if (/\s/.test(char)) {
      index += 1;
    } else if (char === "-" && body[index + 1] === "-") {
      const end = body.indexOf("\n", index);
      index = end < 0 ? body.length : end;
    } else if (char === "/" && body[index + 1] === "*") {
      const end = body.indexOf("*/", index + 2);
      index = end < 0 ? body.length : end + 2;
    } else if (char === "'") {
      let end = index + 1;
      while (end < body.length) {
        if (body[end] === "'" && body[end + 1] === "'") end += 2;
        else if (body[end] === "'") break;
        else end += 1;
      }
      tokens.push({ type: "literal", value: body.slice(index + 1, end).replaceAll("''", "'"), start: index, end: end + 1 });
      index = end + 1;
    } else if (IDENTIFIER_START.test(char)) {
      let end = index + 1;
      while (end < body.length && IDENTIFIER_PART.test(body[end])) end += 1;
      tokens.push({ type: "word", value: body.slice(index, end).toLowerCase(), start: index, end });
      index = end;
    } else {
      tokens.push({ type: "punct", value: char, start: index, end: index + 1 });
      index += 1;
    }
  }
  return tokens;
}

function literalsBeforeThen(tokens, from) {
  const literals = [];
  let cursor = from;
  while (cursor < tokens.length && tokens[cursor].value !== "then") {
    if (tokens[cursor].type === "literal") literals.push(tokens[cursor].value);
    cursor += 1;
  }
  return { literals, thenIndex: cursor };
}

/**
 * Finds the first simple `case <variable>` statement and returns its arms. Nested blocks (`begin`,
 * `if`, `loop`, SQL `case` expressions) are skipped by depth, so only the top-level `when` arms count.
 * @returns {{ variable: string, branches: { operations: string[], text: string }[], fallthrough: string | null } | null}
 */
export function extractCaseBranches(body) {
  const tokens = tokenizeBody(body);
  let depth = 0;
  let target = null;
  let variable = null;
  const branches = [];
  let current = null;
  let fallthrough = null;
  const close = (endOffset) => {
    if (!current) return;
    const text = body.slice(current.start, endOffset);
    if (current.operations) branches.push({ operations: current.operations, text });
    else fallthrough = text;
    current = null;
  };
  for (let index = 0; index < tokens.length; index += 1) {
    const token = tokens[index];
    if (token.type !== "word") continue;
    if (token.value === "end") {
      if (target !== null && depth === target) {
        close(token.start);
        break;
      }
      depth -= 1;
      const next = tokens[index + 1];
      if (next?.type === "word" && BLOCK_OPENERS.has(next.value)) index += 1;
      continue;
    }
    if (BLOCK_OPENERS.has(token.value)) {
      depth += 1;
      const next = tokens[index + 1];
      if (token.value === "case" && target === null && next?.type === "word" && next.value !== "when") {
        target = depth;
        variable = next.value;
      }
      continue;
    }
    if (target === null || depth !== target) continue;
    if (token.value === "when") {
      const { literals, thenIndex } = literalsBeforeThen(tokens, index + 1);
      if (literals.length === 0) continue;
      close(token.start);
      current = { operations: literals, start: tokens[thenIndex]?.end ?? token.end };
      index = thenIndex;
    } else if (token.value === "else") {
      close(token.start);
      current = { operations: null, start: token.end };
    }
  }
  if (target === null) return null;
  close(body.length);
  return { variable, branches, fallthrough };
}
