-- Build 08 D-82 follow-up (lab draft): the client-grant check of api.product_read, callable on its own.
begin;

-- 4. A scoped client grant (x-aieng-client-token) narrows what a CLI, MCP or harness client may do. api.product_command and
--    api.product_read check it; the knowledge reads the service composes from the api views and functions had no check, so a
--    client holding a grant without the read scope, or a revoked one, could still read them. api.product_scope is the same check
--    (product.actor(), product.client_grant) for a named scope, with no workspace: the service calls it before a knowledge read
--    whenever the request carries a client token. Without a token it reports that no grant applies.
create or replace function api.product_scope(p_scope text) returns jsonb
language plpgsql security definer set search_path = '' as $function$
declare p uuid := product.actor(); g access.client_grant;
begin
  if p_scope is null or not (p_scope = any(array['read','author','learn','library','assess'])) then perform product.fail('VALIDATION', 'scope'); end if;
  g := product.client_grant(p_scope, null);
  return jsonb_build_object('principalId', p, 'clientGrantId', g.id, 'clientKind', g.client_kind);
end $function$;
comment on function api.product_scope(text) is
 'The client-grant check of api.product_read for a named scope (read, author, learn, library, assess), for reads composed outside it (D-82): raises AUTH_REQUIRED, CLIENT_GRANT_INVALID or CLIENT_SCOPE_DENIED like the product operations; returns the principal and the grant that applies (clientGrantId is null when the request carries no client token).';
grant create on schema api to product_api_owner;   -- needed only to transfer ownership; revoked below
alter function api.product_scope(text) owner to product_api_owner;
revoke create on schema api from product_api_owner;
revoke all on function api.product_scope(text) from public, anon;
grant execute on function api.product_scope(text) to authenticated;

commit;
