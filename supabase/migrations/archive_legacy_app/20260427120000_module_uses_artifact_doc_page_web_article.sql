-- Align module_uses_artifact artifact kinds with vault upsert-modules.ts (docs→doc_page,
-- web→web_article) and chunk corpus kinds added in 20260420000000.

alter table public.module_uses_artifact drop constraint if exists module_uses_artifact_kind_check;

alter table public.module_uses_artifact add constraint module_uses_artifact_kind_check check (
  artifact_kind in (
    'video', 'session', 'dossier', 'repo', 'library', 'product',
    'paper', 'slide', 'report', 'news_item', 'chunk',
    'doc_page', 'web_article'
  )
);
