-- Build 08 loop 2 draft, fixup 4 (2026-11-09): D-36 the structured paper digest of §15.3 P1 needs item kinds beyond loop 1's seven
-- (problem, method, key_result, artifact, practitioner_change); the check constraint is the item-kind vocabulary.
begin;
alter table content.digest_item drop constraint if exists digest_item_item_kind_check;
alter table content.digest_item add constraint digest_item_item_kind_check check (item_kind in ('key_point','entity_role','assertion_ref','change','open_question','limitation','research_direction','problem','method','key_result','artifact','practitioner_change'));
comment on column content.digest_item.item_kind is 'key_point | entity_role | assertion_ref | change | open_question | limitation | research_direction | problem | method | key_result | artifact | practitioner_change (the last five are the P1 structured paper digest of Build 08 §15.3).';
commit;
