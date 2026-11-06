import { idTail } from "../ir/ids.mjs";
import { code, link } from "./markdown.mjs";

/** Link to a relation page, or a bare code span when the target is out of selection. */
export function relationLink(model, fromPage, relationId, label = null) {
  const target = model.relationPage(relationId);
  const text = label ?? idTail(relationId);
  return target ? link(code(text), fromPage, target) : code(text);
}

/** Link to a function page, or a bare code span when the target is out of selection. */
export function functionLink(model, fromPage, functionId, label = null) {
  const target = model.functionPage(functionId);
  const fn = model.ir.functions[functionId];
  const text = label ?? (fn ? `${fn.schema}.${fn.name}` : functionId);
  return target ? link(code(text), fromPage, target) : code(text);
}

/** `touches.reads` stores `schema.name`; resolve it through the same relation-page rule. */
export function relationRef(model, fromPage, qualifiedName) {
  return relationLink(model, fromPage, `rel:${qualifiedName}`);
}
