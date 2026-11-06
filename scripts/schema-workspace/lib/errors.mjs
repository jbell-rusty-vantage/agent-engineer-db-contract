export const ErrorCode = Object.freeze({
  DB_UNREACHABLE: "DB_UNREACHABLE",
  HEAD_MISMATCH: "HEAD_MISMATCH",
  TYPES_OUT_OF_DATE: "TYPES_OUT_OF_DATE",
  ENRICHMENT_INVALID: "ENRICHMENT_INVALID",
  SIZE_BUDGET_EXCEEDED: "SIZE_BUDGET_EXCEEDED",
  BROKEN_LINK: "BROKEN_LINK",
  EXAMPLE_FAILED: "EXAMPLE_FAILED",
  VALIDATION_FAILED: "VALIDATION_FAILED",
  SCOPE_INVALID: "SCOPE_INVALID",
  USAGE: "USAGE",
  IO: "IO",
});

/** Exit lattice: 0 ok, 1 domain outcome (validation/drift), 2 infrastructure. */
export const ExitCode = Object.freeze({ OK: 0, DOMAIN: 1, INFRASTRUCTURE: 2 });

const domainCodes = new Set([
  ErrorCode.ENRICHMENT_INVALID,
  ErrorCode.SIZE_BUDGET_EXCEEDED,
  ErrorCode.BROKEN_LINK,
  ErrorCode.EXAMPLE_FAILED,
  ErrorCode.VALIDATION_FAILED,
  ErrorCode.HEAD_MISMATCH,
  ErrorCode.TYPES_OUT_OF_DATE,
]);

export class WorkspaceError extends Error {
  constructor(code, message, details = undefined) {
    super(message);
    this.name = "WorkspaceError";
    this.code = code;
    this.details = details;
  }

  get exitCode() {
    return domainCodes.has(this.code) ? ExitCode.DOMAIN : ExitCode.INFRASTRUCTURE;
  }

  toJSON() {
    return { code: this.code, message: this.message, ...(this.details ? { details: this.details } : {}) };
  }
}
