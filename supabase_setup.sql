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
  category text not null default 'work' check (category in ('work', 'personal', 'milestone', 'daily')),
  done boolean not null default false,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tracker_tasks enable row level security;

alter table public.tracker_tasks
add column if not exists category text not null default 'work';

alter table public.tracker_tasks
drop constraint if exists tracker_tasks_category_check;

alter table public.tracker_tasks
add constraint tracker_tasks_category_check
check (category in ('work', 'personal', 'milestone', 'daily'));

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

insert into public.tracker_tasks (id, owner, title, due, priority, category, done, position)
values
  ('n-1', 'nandana', 'Get passport photos', 'Tuesday', 'critical', 'personal', false, 1),
  ('n-2', 'nandana', 'Book health screening', 'Tuesday', 'critical', 'personal', false, 2),
  ('n-3', 'nandana', 'Lighting inputs for Energy Team', 'Tuesday', 'work', 'work', false, 3),
  ('n-4', 'nandana', 'Finalise Qiddiya tracker', 'Tuesday', 'critical', 'work', false, 4),
  ('n-5', 'nandana', 'Architects markups and email', 'Tuesday', 'work', 'work', false, 5),
  ('n-6', 'nandana', 'Catch-up call with Dalia', 'Wednesday', 'high', 'work', false, 6),
  ('n-7', 'nandana', 'Heat and Tile innovation research', 'Wednesday', 'high', 'milestone', false, 7),
  ('n-8', 'nandana', 'Understand Ghaf project scope', 'Wednesday', 'work', 'milestone', false, 8),
  ('n-9', 'nandana', 'Schedule mentor meeting', 'Thursday', 'high', 'milestone', false, 9),
  ('n-10', 'nandana', 'Take Harvard Test', 'Friday', 'high', 'milestone', false, 10),
  ('n-11', 'nandana', 'Finish 1.5 M1 Reports', 'Friday', 'critical', 'work', false, 11),
  ('n-12', 'nandana', 'Meet Ashni and return ornaments', 'Saturday', 'personal', 'personal', false, 12),
  ('n-13', 'nandana', 'Begin Point Estate execution', 'This week', 'work', 'milestone', false, 13),
  ('n-14', 'nandana', 'Visit a cafe', 'Weekend', 'personal', 'personal', false, 14),
  ('n-15', 'nandana', 'Pilates or group class', 'Weekend', 'personal', 'daily', false, 15),
  ('n-16', 'nandana', 'Research sustainable materials', 'This week', 'high', 'milestone', false, 16),
  ('n-17', 'nandana', 'Research passive cooling', 'This week', 'high', 'milestone', false, 17),
  ('n-18', 'nandana', 'Research heat-resistant facades and smart coatings', 'This week', 'high', 'milestone', false, 18),
  ('s-1', 'sreerag', 'Complete the G instance finance report', 'This week', 'work', 'work', false, 101),
  ('s-2', 'sreerag', 'Complete automation for daily used GPU collection', 'This week', 'work', 'work', false, 102),
  ('s-3', 'sreerag', 'Send Mirador report with explanation', 'This week', 'critical', 'work', false, 103),
  ('s-4', 'sreerag', 'Hide from Swarna about interview', 'This week', 'high', 'personal', false, 104),
  ('s-5', 'sreerag', 'Give interview', 'This week', 'high', 'milestone', false, 105),
  ('s-6', 'sreerag', 'Apply to 30 jobs in Dubai per day', 'Daily', 'high', 'milestone', false, 106),
  ('s-7', 'sreerag', 'Gym on Tuesday, Thursday, Friday and Saturday morning', 'Tue/Thu/Fri/Sat', 'personal', 'daily', false, 107),
  ('s-8', 'sreerag', 'Increase calorie intake', 'Daily', 'personal', 'daily', false, 108),
  ('s-9', 'sreerag', 'FSX movement tracker project', 'This week', 'work', 'work', false, 109),
  ('s-10', 'sreerag', 'Olympus pretraining us-east-1 cleanup', 'This week', 'critical', 'work', false, 110),
  ('s-11', 'sreerag', 'Upscale on Sev 2 tickets and take the handover', 'This week', 'critical', 'work', false, 111),
  ('s-12', 'sreerag', 'Pipeline change task and push for start day', 'This week', 'high', 'work', false, 112),
  ('s-13', 'sreerag', 'Call Nandana daily', 'Daily', 'personal', 'daily', false, 113),
  ('s-14', 'sreerag', 'Life insurance premium to be paid', 'This week', 'personal', 'personal', false, 114),
  ('s-15', 'sreerag', 'Design and launch the mobile update for older iOS Together', 'This week', 'high', 'milestone', false, 115),
  ('s-16', 'sreerag', 'Plan Bangalore relaunch', 'This week', 'high', 'milestone', false, 116),
  ('s-17', 'sreerag', 'Complete one book reading', 'This week', 'personal', 'personal', false, 117),
  ('s-18', 'sreerag', 'Create online tracker', 'This week', 'work', 'milestone', false, 118)
on conflict (id) do update
set owner = excluded.owner,
    title = excluded.title,
    due = excluded.due,
    priority = excluded.priority,
    category = excluded.category,
    position = excluded.position;
