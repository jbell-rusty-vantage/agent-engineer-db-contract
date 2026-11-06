-- Add 'web_article' to chunk.source_kind allowlist.
--
-- The agent-skills slice ingests external web pages (Anthropic's engineering
-- post, the agentskills.io standard page, etc.) into the chunk store. These
-- aren't doc_page (which is library docs), nor repo_readme. They're standalone
-- web articles. Extending the check constraint here so the chunker can emit
-- 'web_article' source_kind without violating the constraint.

alter table public.chunk drop constraint if exists chunk_source_kind_check;

alter table public.chunk add constraint chunk_source_kind_check check (
  source_kind in (
    'video_summary', 'video_transcript_segment', 'video_description', 'video_chapter',
    'session_description',
    'doc_page', 'repo_readme', 'repo_example', 'repo_doc',
    'paper_abstract', 'paper_section',
    'slide', 'dossier', 'report_section', 'news_item_body', 'module_body',
    'web_article',
    'custom'
  )
);

comment on constraint chunk_source_kind_check on public.chunk is
  'Enumerated artifact kind. Add new values here when ingestion needs them. v2 (2026-04-20): added web_article for standalone external articles.';
