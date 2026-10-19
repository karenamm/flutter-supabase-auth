-- Perfil de cada cuenta: mismo id que auth.users (paso 2 del registro).
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  full_name text not null
);

-- Solo usuarios con sesión; nada para anon.
revoke all on public.profiles from anon;
grant select, insert, update on public.profiles to authenticated;

-- Cada usuario solo ve y modifica su propia fila.
alter table public.profiles enable row level security;

create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);

create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
