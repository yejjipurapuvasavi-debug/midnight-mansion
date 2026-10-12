-- Supabase starter schema for The Midnight Mansion.
-- Run in Supabase SQL Editor only after reading README.md.
-- This schema separates public viewing from contributor writes.
create extension if not exists pgcrypto;

create table if not exists public.contributors (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'contributor' check (role in ('admin','contributor')),
  created_at timestamptz not null default now()
);

create table if not exists public.invite_codes (
  id uuid primary key default gen_random_uuid(),
  code_hash text not null unique,
  email text not null,
  role text not null default 'contributor' check (role in ('admin','contributor')),
  expires_at timestamptz not null,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.friends (
  id uuid primary key default gen_random_uuid(),
  nickname text not null,
  role_description text,
  green_flag text,
  red_flag text,
  funny_secret text,
  most_likely_to text,
  photo_path text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.memories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  memory_date date,
  place_label text,
  caption text,
  photo_path text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.song_dedications (
  id uuid primary key default gen_random_uuid(),
  friend_nickname text not null,
  language text not null check (language in ('Telugu','Hindi','English','Other')),
  song_title text not null,
  movie_or_artist text,
  official_url text not null,
  dedication_note text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.secret_messages (
  id uuid primary key default gen_random_uuid(),
  recipient_nickname text not null,
  message text not null,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.contributors enable row level security;
alter table public.invite_codes enable row level security;
alter table public.friends enable row level security;
alter table public.memories enable row level security;
alter table public.song_dedications enable row level security;
alter table public.secret_messages enable row level security;

-- Public read for non-sensitive content. Do not put private messages in a public table.
create policy "public can view friend profiles" on public.friends for select using (true);
create policy "contributors can add friend profiles" on public.friends for insert to authenticated with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can edit friend profiles" on public.friends for update to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid())) with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can delete friend profiles" on public.friends for delete to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid()));

create policy "public can view memories" on public.memories for select using (true);
create policy "contributors can add memories" on public.memories for insert to authenticated with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can edit memories" on public.memories for update to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid())) with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can delete memories" on public.memories for delete to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid()));

create policy "public can view song dedications" on public.song_dedications for select using (true);
create policy "contributors can add song dedications" on public.song_dedications for insert to authenticated with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can edit song dedications" on public.song_dedications for update to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid())) with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can delete song dedications" on public.song_dedications for delete to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid()));

-- Secret messages are deliberately not public. Recipients/contributors need a future per-user recipient mapping policy.
create policy "contributors can view secret messages" on public.secret_messages for select to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can add secret messages" on public.secret_messages for insert to authenticated with check (exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can delete secret messages" on public.secret_messages for delete to authenticated using (exists(select 1 from public.contributors c where c.user_id=auth.uid()));

-- Only the edge function/service role should read or mutate invite codes.
-- No direct policies are granted to anon or authenticated for invite_codes/contributors.

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('mansion-photos','mansion-photos',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "public can view mansion photos" on storage.objects for select using (bucket_id='mansion-photos');
create policy "contributors can upload mansion photos" on storage.objects for insert to authenticated with check (bucket_id='mansion-photos' and exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can update mansion photos" on storage.objects for update to authenticated using (bucket_id='mansion-photos' and exists(select 1 from public.contributors c where c.user_id=auth.uid())) with check (bucket_id='mansion-photos' and exists(select 1 from public.contributors c where c.user_id=auth.uid()));
create policy "contributors can delete mansion photos" on storage.objects for delete to authenticated using (bucket_id='mansion-photos' and exists(select 1 from public.contributors c where c.user_id=auth.uid()));
