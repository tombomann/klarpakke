-- 1. Create Profiles Table (Public info)
create table if not exists public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  plan text default 'free', -- 'free', 'trader', 'whale'
  is_paper_trading boolean default true,
  stripe_customer_id text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create User Secrets Table (Encrypted keys)
-- Only service_role or the user themselves should see this
create table if not exists public.user_secrets (
  user_id uuid references auth.users not null primary key,
  binance_api_key_encrypted text,
  binance_api_secret_encrypted text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable RLS (Row Level Security)
alter table public.profiles enable row level security;
alter table public.user_secrets enable row level security;

-- 4. Policies (Profiles)
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- 5. Policies (Secrets) - STRICT!
create policy "Users can manage own secrets."
  on user_secrets for all
  using ( auth.uid() = user_id );

-- 6. Trigger: Create Profile on Signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
