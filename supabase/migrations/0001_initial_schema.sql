-- StayLatin initial schema: traveler profiles, saved stays, and guest reviews.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  preferred_language text not null default 'en' check (preferred_language in ('en', 'es', 'pt')),
  created_at timestamptz not null default now()
);

create table if not exists public.saved_stays (
  user_id uuid not null references auth.users (id) on delete cascade,
  stay_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, stay_id)
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  stay_id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  rating numeric(3, 1) not null check (rating >= 1 and rating <= 10),
  body text not null check (char_length(body) between 10 and 2000),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.saved_stays enable row level security;
alter table public.reviews enable row level security;

create policy "Users read their own profile"
  on public.profiles for select using (auth.uid() = id);
create policy "Users update their own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users manage their own saved stays"
  on public.saved_stays for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Anyone reads approved reviews"
  on public.reviews for select using (status = 'approved');
create policy "Users read their own reviews"
  on public.reviews for select using (auth.uid() = user_id);
create policy "Users write their own reviews"
  on public.reviews for insert with check (auth.uid() = user_id and status = 'pending');
