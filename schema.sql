-- SplitCrew database schema
-- Run this once in your Supabase project: Project → SQL Editor → New query → paste → Run

-- 1. The table itself. Same shape as the old window.storage: a key, a JSON value.
create table if not exists kv_store (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Lock the table down completely. Row Level Security with NO policies means
--    nobody can query it directly, not even with the public anon key.
alter table kv_store enable row level security;
revoke all on kv_store from anon, authenticated;

-- 3. The only way in: three functions that require the exact key, one at a time.
--    This preserves the app's original security model — knowing a crew's code
--    (or share link) is what grants access, and there is no way to list or
--    browse other crews' data, unlike a plain "select * from kv_store" would allow.

create or replace function kv_get(p_key text)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select value from kv_store where key = p_key;
$$;

create or replace function kv_set(p_key text, p_value jsonb)
returns void
language sql
security definer
set search_path = public
as $$
  insert into kv_store (key, value, updated_at)
  values (p_key, p_value, now())
  on conflict (key) do update set value = excluded.value, updated_at = now();
$$;

create or replace function kv_delete(p_key text)
returns void
language sql
security definer
set search_path = public
as $$
  delete from kv_store where key = p_key;
$$;

-- 4. Let the public (anonymous, no-login) API key call these three functions —
--    but grant nothing on the table itself, which stays locked in step 2.
grant execute on function kv_get(text) to anon, authenticated;
grant execute on function kv_set(text, jsonb) to anon, authenticated;
grant execute on function kv_delete(text) to anon, authenticated;

-- 5. Tell Supabase's API layer (PostgREST) to pick up these new functions
--    immediately, instead of waiting for its next automatic cache refresh.
--    Skipping this is the #1 cause of a 404 (PGRST202) "function not found"
--    error right after running this script for the first time.
NOTIFY pgrst, 'reload schema';
