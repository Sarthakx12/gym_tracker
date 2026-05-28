-- ============================================================
-- GymTracker Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Profiles (auto-created on signup)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  created_at timestamptz default now()
);

-- Exercises
create table if not exists public.exercises (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  muscle_group text not null,
  equipment text not null,
  is_default boolean default false,
  created_at timestamptz default now()
);

-- Workout sessions
create table if not exists public.workout_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  local_id integer,
  name text not null,
  start_time timestamptz not null,
  end_time timestamptz,
  notes text,
  heart_rate integer,
  calories integer,
  created_at timestamptz default now()
);

-- Exercise logs
create table if not exists public.exercise_logs (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references public.workout_sessions on delete cascade not null,
  exercise_name text not null,
  order_index integer not null,
  created_at timestamptz default now()
);

-- Workout sets
create table if not exists public.workout_sets (
  id uuid default gen_random_uuid() primary key,
  log_id uuid references public.exercise_logs on delete cascade not null,
  set_number integer not null,
  weight real not null,
  reps integer not null,
  rest_seconds integer,
  created_at timestamptz default now()
);

-- ── Row Level Security ──────────────────────────────────────
alter table public.profiles         enable row level security;
alter table public.exercises        enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.exercise_logs    enable row level security;
alter table public.workout_sets     enable row level security;

-- Policies
create policy "Own profiles"  on public.profiles         for all using (auth.uid() = id);
create policy "Own exercises" on public.exercises        for all using (auth.uid() = user_id);
create policy "Own sessions"  on public.workout_sessions for all using (auth.uid() = user_id);

create policy "Own logs" on public.exercise_logs for all using (
  session_id in (
    select id from public.workout_sessions where user_id = auth.uid()
  )
);

create policy "Own sets" on public.workout_sets for all using (
  log_id in (
    select el.id from public.exercise_logs el
    join public.workout_sessions ws on ws.id = el.session_id
    where ws.user_id = auth.uid()
  )
);

-- ── Auto-create profile on signup ───────────────────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
