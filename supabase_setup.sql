-- Run this once in Supabase: Project → SQL Editor → New query → paste → Run

create table if not exists screeners (
  id bigint primary key,
  payload jsonb not null,
  created_at timestamptz default now()
);

-- This is a public field-survey tool with no login, so we allow the
-- anonymous (anon) key to insert, select, and delete freely. There is no
-- per-user auth in this app; every interviewer shares the same data pool.
-- If you want to lock this down later, replace these permissive policies
-- with ones scoped to an authenticated role.

alter table screeners enable row level security;

create policy "anon can insert" on screeners
  for insert to anon
  with check (true);

create policy "anon can select" on screeners
  for select to anon
  using (true);

create policy "anon can delete" on screeners
  for delete to anon
  using (true);
