---
id: "voc:evidence.capture_method"
kind: vocabulary
schema: evidence
name: capture_method
rows: 15
rows_sha256: "sha256:e233a3d54513c174ca4fb2faf152be96046c0e06b173b7ac4febf3a8c36ea9d9"
codes: [api, apify_actor, browser, firecrawl, http, https_acquire, manual, native_harness_http, other, probe_execution, repository, whisper_upload, youtube_captions, youtube_transcript, yt_dlp]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# evidence.capture_method

Reference data snapshot (15 rows, digest `sha256:e233a3d54513c174ca4fb2faf152be96046c0e06b173b7ac4febf3a8c36ea9d9`). Codes are enforced wherever a column has a foreign key to [`evidence.capture_method`](../relations/evidence/capture_method.md).

| code | description |
| --- | --- |
| `api` | api |
| `apify_actor` | apify_actor |
| `browser` | browser |
| `firecrawl` | firecrawl |
| `http` | http |
| `https_acquire` | Trusted exact HTTPS acquisition through an admitted source grant |
| `manual` | manual |
| `native_harness_http` | Fetched by a coding-harness agent over plain HTTPS; provenance in acquisition.fetch |
| `other` | other |
| `probe_execution` | Output of a probe run executed by this system in a recorded environment (lockfile, interpreter, platform) |
| `repository` | repository |
| `whisper_upload` | whisper_upload |
| `youtube_captions` | youtube_captions |
| `youtube_transcript` | youtube_transcript |
| `yt_dlp` | yt_dlp |
