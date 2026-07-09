-- Weekly Tracker Supabase setup
-- 1. Change CHANGE_ME_TRACKER_CODE below to your private tracker access code.
-- 2. Run this entire file in Supabase SQL Editor.
-- 3. Share the access code only with people who should edit the tracker.

create extension if not exists pgcrypto;

create table if not exists public.tracker_config (
  id text primary key,
  access_code_hash text not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.tracker_state (
  id text primary key,
  payload jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.tracker_config enable row level security;
alter table public.tracker_state enable row level security;

revoke all on public.tracker_config from anon, authenticated;
revoke all on public.tracker_state from anon, authenticated;

insert into public.tracker_config (id, access_code_hash)
values ('main', crypt('CHANGE_ME_TRACKER_CODE', gen_salt('bf')))
on conflict (id) do update
set access_code_hash = excluded.access_code_hash,
    updated_at = now();

insert into public.tracker_state (id, payload)
values ('main', '[]'::jsonb)
on conflict (id) do nothing;

create or replace function public.tracker_code_is_valid(p_access_code text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.tracker_config
    where id = 'main'
      and access_code_hash = crypt(p_access_code, access_code_hash)
  );
$$;

create or replace function public.get_tracker_state(p_access_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.tracker_code_is_valid(p_access_code) then
    raise exception 'Invalid tracker access code';
  end if;

  return (
    select payload
    from public.tracker_state
    where id = 'main'
  );
end;
$$;

create or replace function public.save_tracker_state(p_access_code text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.tracker_code_is_valid(p_access_code) then
    raise exception 'Invalid tracker access code';
  end if;

  insert into public.tracker_state (id, payload, updated_at)
  values ('main', coalesce(p_payload, '[]'::jsonb), now())
  on conflict (id) do update
  set payload = excluded.payload,
      updated_at = now();

  return (
    select payload
    from public.tracker_state
    where id = 'main'
  );
end;
$$;

revoke all on function public.tracker_code_is_valid(text) from public, anon, authenticated;
revoke all on function public.get_tracker_state(text) from public, anon, authenticated;
revoke all on function public.save_tracker_state(text, jsonb) from public, anon, authenticated;

grant execute on function public.get_tracker_state(text) to anon;
grant execute on function public.save_tracker_state(text, jsonb) to anon;
