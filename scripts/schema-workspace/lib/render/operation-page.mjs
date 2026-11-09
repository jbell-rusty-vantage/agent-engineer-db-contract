import { functionLink, relationRef } from "./links.mjs";
import { code, frontmatter, heading, joinBlocks, link, table } from "./markdown.mjs";
import { pages } from "./model.mjs";

const OPERATION_LENS = "ours";
const OPERATION_ARGUMENT = "p_operation";

/** `api.product_command(p_workspace_id, 'create_work', p_idempotency_key, p_expected_head, p_payload)` from the wrapper's real signature. */
export function callExpression(model, operation) {
  const wrapper = operation.call_function_id ? model.ir.functions[operation.call_function_id] : null;
  const names = wrapper ? wrapper.arguments.map((argument) => (argument.name === OPERATION_ARGUMENT ? `'${operation.name}'` : argument.name ?? argument.type)) : [`'${operation.name}'`, "p_payload"];
  return `select ${operation.call}(${names.join(", ")})`;
}

export function operationSummary(operation) {
  const touched = [...operation.writes, ...operation.reads];
  return `${operation.dispatcher} operation via ${operation.call}; touches ${touched.length > 0 ? touched.join(", ") : "no catalog relation directly"}.`;
}

/** One page per product operation: where it is dispatched, how to call it, which relations the arm touches. */
export function renderOperationPage(model, operation) {
  const page = pages.operation(operation.name);
  const wrapper = operation.call_function_id ? model.ir.functions[operation.call_function_id] : null;
  const executors = wrapper ? wrapper.executors.filter((role) => role !== "service_role" || operation.dispatcher === "worker") : [];
  const dispatcherLink = operation.function_id ? functionLink(model, page, operation.function_id) : code(operation.function);
  const callLink = operation.call_function_id ? functionLink(model, page, operation.call_function_id) : code(operation.call);
  const rows = [
    ...operation.writes.map((name) => [relationRef(model, page, name), "write"]),
    ...operation.reads.map((name) => [relationRef(model, page, name), "read"]),
  ];
  const helpers = operation.calls.map((name) => {
    const overloads = model.ir.derived.function_ids_by_name[name] ?? [];
    const target = overloads.length > 0 ? model.functionPage(overloads[0]) : null;
    return target ? link(code(name), page, target) : code(name);
  });
  const content =
    frontmatter({
      id: operation.id,
      kind: "operation",
      name: operation.name,
      dispatcher: operation.dispatcher,
      function: operation.function,
      call: operation.call,
      lens: OPERATION_LENS,
      relations: [...operation.writes, ...operation.reads].sort(),
      tokens: [operation.name, operation.dispatcher, operation.call],
      workspace_fingerprint: model.buildInfo.workspace_fingerprint,
    }) +
    joinBlocks([
      heading(1, operation.name),
      `Product operation: the ${code(`when '${operation.name}' then`)} arm of ${dispatcherLink} (dispatcher ${code(operation.dispatcher)}), reached through ${callLink}. Derived from the function body; relation list is best effort.`,
      heading(2, "How to call"),
      `\`\`\`sql\n${callExpression(model, operation)}\n\`\`\`\n${executors.length > 0 ? `Execute: ${executors.map(code).join(", ")}. ` : ""}${operation.dispatcher === "worker" ? "Worker credential (service_role JWT) required." : "The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions."}`,
      heading(2, "Relations the arm touches"),
      table(["Relation", "Access"], rows),
      helpers.length > 0 ? `${heading(2, "Helpers called")}\n${helpers.join(", ")}\n` : "",
    ]);
  return { path: page, content };
}
