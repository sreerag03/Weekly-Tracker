-- Weekly Tracker Supabase setup
-- Run this entire file in Supabase SQL Editor.
-- This setup allows the GitHub Pages site to read/write tracker tasks directly
-- with the public publishable key. Do not put secret/service_role keys in the site.

create table if not exists public.tracker_tasks (
  id text primary key,
  owner text not null check (owner in ('nandana', 'sreerag')),
  title text not null,
  due text not null default 'This week',
  priority text not null default 'work' check (priority in ('critical', 'high', 'personal', 'work')),
  done boolean not null default false,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tracker_tasks enable row level security;

drop policy if exists "weekly tracker public read" on public.tracker_tasks;
drop policy if exists "weekly tracker public insert" on public.tracker_tasks;
drop policy if exists "weekly tracker public update" on public.tracker_tasks;
drop policy if exists "weekly tracker public delete" on public.tracker_tasks;

create policy "weekly tracker public read"
on public.tracker_tasks
for select
to anon
using (true);

create policy "weekly tracker public insert"
on public.tracker_tasks
for insert
to anon
with check (true);

create policy "weekly tracker public update"
on public.tracker_tasks
for update
to anon
using (true)
with check (true);

create policy "weekly tracker public delete"
on public.tracker_tasks
for delete
to anon
using (true);

grant select, insert, update, delete on public.tracker_tasks to anon;

create or replace function public.set_tracker_tasks_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tracker_tasks_updated_at on public.tracker_tasks;
create trigger tracker_tasks_updated_at
before update on public.tracker_tasks
for each row
execute function public.set_tracker_tasks_updated_at();
