-- Chopmark: Phase 1 schema.
-- Paste this whole file into the Supabase SQL editor and press Run.
-- It is safe to run more than once.

-- ---------------------------------------------------------------------------
-- Dealers: one row per login. Created automatically when someone signs up.
-- ---------------------------------------------------------------------------
create table if not exists public.dealers (
  id         uuid primary key references auth.users (id) on delete cascade,
  name       text not null,
  slug       text not null unique,
  bio        text,          -- used by the Phase 2 storefront
  logo_url   text,          -- used by the Phase 2 storefront
  created_at timestamptz not null default now()
);

create or replace function public.slugify(value text)
returns text language sql immutable as $$
  select coalesce(
    nullif(trim(both '-' from regexp_replace(lower(coalesce(value, '')), '[^a-z0-9]+', '-', 'g')), ''),
    'dealer'
  );
$$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  dealer_name text;
  base        text;
  candidate   text;
  n           int := 1;
begin
  dealer_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'dealer_name'), ''),
    split_part(coalesce(new.email, 'dealer'), '@', 1)
  );
  base := public.slugify(dealer_name);
  candidate := base;
  while exists (select 1 from public.dealers where slug = candidate) loop
    n := n + 1;
    candidate := base || '-' || n;
  end loop;

  insert into public.dealers (id, name, slug)
  values (new.id, dealer_name, candidate)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Logins that already existed before this file was first run get a dealer row too.
insert into public.dealers (id, name, slug)
select u.id, n.name, public.slugify(n.name) || '-' || left(u.id::text, 6)
from auth.users u
cross join lateral (
  select coalesce(nullif(trim(u.raw_user_meta_data ->> 'dealer_name'), ''), split_part(coalesce(u.email, 'dealer'), '@', 1)) as name
) n
where not exists (select 1 from public.dealers d where d.id = u.id);

-- ---------------------------------------------------------------------------
-- Items. Every item gets a GOID: 8 characters, no 0/O/1/I/L so it can be
-- read off a label and typed.
-- ---------------------------------------------------------------------------
create table if not exists public.items (
  id         uuid primary key default gen_random_uuid(),
  goid       text not null unique check (goid ~ '^[A-Z0-9]{8}$'),
  dealer_id  uuid not null default auth.uid() references public.dealers (id) on delete cascade,
  name       text not null check (length(trim(name)) > 0),
  category   text not null check (category in ('coins', 'cards', 'comics', 'stamps', 'watches', 'art')),
  price      numeric(12, 2) check (price is null or price >= 0),
  condition  text,
  notes      text,
  status     text not null default 'in_stock' check (status in ('in_stock', 'hold', 'sold')),
  photos     text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  sold_at    timestamptz
);

create index if not exists items_dealer_idx on public.items (dealer_id, created_at desc);

create or replace function public.gen_goid()
returns text language plpgsql volatile set search_path = public as $$
declare
  alphabet  constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  candidate text;
begin
  loop
    candidate := '';
    for i in 1..8 loop
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.items where goid = candidate);
  end loop;
  return candidate;
end;
$$;

alter table public.items alter column goid set default public.gen_goid();

-- Keeps the fields a dealer must not be able to change.
create or replace function public.items_guard()
returns trigger language plpgsql set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    -- Requests coming through the API always get a fresh GOID and timestamp.
    -- (The seed file runs without a logged-in user and keeps its own values.)
    if auth.uid() is not null then
      new.goid := public.gen_goid();
      new.created_at := now();
    end if;
    new.updated_at := new.created_at;
    if new.status = 'sold' and new.sold_at is null then
      new.sold_at := new.created_at;
    end if;
    return new;
  end if;

  new.id := old.id;
  new.goid := old.goid;
  new.dealer_id := old.dealer_id;
  new.created_at := old.created_at;
  new.updated_at := now();
  if new.status = 'sold' and old.status <> 'sold' then
    new.sold_at := now();
  elsif new.status <> 'sold' then
    new.sold_at := null;
  end if;
  return new;
end;
$$;

drop trigger if exists items_guard on public.items;
create trigger items_guard
  before insert or update on public.items
  for each row execute function public.items_guard();

-- ---------------------------------------------------------------------------
-- Events: the item's history. Written by the trigger below, never by the app,
-- so nothing changes without leaving a record. Dealers can add notes but can
-- never edit or delete history.
-- ---------------------------------------------------------------------------
create table if not exists public.events (
  id         bigint generated always as identity primary key,
  item_id    uuid not null references public.items (id) on delete cascade,
  type       text not null check (type in ('added', 'repriced', 'sold', 'held', 'restocked', 'transferred', 'noted')),
  detail     jsonb not null default '{}',
  note       text,
  actor_id   uuid default auth.uid(),
  created_at timestamptz not null default now()
);

create index if not exists events_item_idx on public.events (item_id, created_at desc);

create or replace function public.log_item_event()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    insert into public.events (item_id, type, detail, actor_id, created_at)
    values (new.id, 'added', jsonb_build_object('price', new.price), auth.uid(), new.created_at);
    return new;
  end if;

  if new.price is distinct from old.price then
    insert into public.events (item_id, type, detail, actor_id)
    values (new.id, 'repriced', jsonb_build_object('from', old.price, 'to', new.price), auth.uid());
  end if;

  if new.status is distinct from old.status then
    insert into public.events (item_id, type, detail, actor_id)
    values (
      new.id,
      case new.status when 'sold' then 'sold' when 'hold' then 'held' else 'restocked' end,
      jsonb_build_object('from', old.status, 'price', new.price),
      auth.uid()
    );
  end if;
  return new;
end;
$$;

drop trigger if exists items_log_event on public.items;
create trigger items_log_event
  after insert or update on public.items
  for each row execute function public.log_item_event();

-- ---------------------------------------------------------------------------
-- Scans (TapLogs). The table and seed data exist now; logging and the dealer
-- view arrive in Phase 2.
-- ---------------------------------------------------------------------------
create table if not exists public.scans (
  id         bigint generated always as identity primary key,
  item_id    uuid not null references public.items (id) on delete cascade,
  scanned_at timestamptz not null default now(),
  device     text,
  referrer   text
);

create index if not exists scans_item_idx on public.scans (item_id, scanned_at desc);

-- ---------------------------------------------------------------------------
-- Row Level Security
--   Anyone can read dealers, items and history (that is the public page).
--   Only the owning dealer can add, change or delete their items.
-- The grants are spelled out because new Supabase projects no longer expose
-- tables to the API automatically.
-- ---------------------------------------------------------------------------
alter table public.dealers enable row level security;
alter table public.items   enable row level security;
alter table public.events  enable row level security;
alter table public.scans   enable row level security;

revoke all on public.dealers, public.items, public.events, public.scans from anon, authenticated;

grant select on public.dealers, public.items, public.events to anon, authenticated;
grant update (name, bio, logo_url) on public.dealers to authenticated;
grant insert, update, delete on public.items to authenticated;
grant insert (item_id, type, note) on public.events to authenticated;
grant select on public.scans to authenticated;
grant execute on function public.gen_goid() to authenticated;

drop policy if exists "Dealers are public" on public.dealers;
create policy "Dealers are public" on public.dealers
  for select using (true);

drop policy if exists "Dealers edit their own profile" on public.dealers;
create policy "Dealers edit their own profile" on public.dealers
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "Items are public" on public.items;
create policy "Items are public" on public.items
  for select using (true);

drop policy if exists "Dealers add their own items" on public.items;
create policy "Dealers add their own items" on public.items
  for insert to authenticated
  with check (dealer_id = auth.uid());

drop policy if exists "Dealers edit their own items" on public.items;
create policy "Dealers edit their own items" on public.items
  for update to authenticated
  using (dealer_id = auth.uid()) with check (dealer_id = auth.uid());

drop policy if exists "Dealers delete their own items" on public.items;
create policy "Dealers delete their own items" on public.items
  for delete to authenticated
  using (dealer_id = auth.uid());

drop policy if exists "History is public" on public.events;
create policy "History is public" on public.events
  for select using (true);

drop policy if exists "Dealers add notes to their own items" on public.events;
create policy "Dealers add notes to their own items" on public.events
  for insert to authenticated
  with check (
    type = 'noted'
    and exists (select 1 from public.items i where i.id = item_id and i.dealer_id = auth.uid())
  );

drop policy if exists "Dealers see scans of their own items" on public.scans;
create policy "Dealers see scans of their own items" on public.scans
  for select to authenticated
  using (exists (select 1 from public.items i where i.id = item_id and i.dealer_id = auth.uid()));

-- ---------------------------------------------------------------------------
-- Photo storage: a public bucket. Each dealer can only write inside a folder
-- named with their own user id.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('item-photos', 'item-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "Dealers upload their own photos" on storage.objects;
create policy "Dealers upload their own photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'item-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Dealers delete their own photos" on storage.objects;
create policy "Dealers delete their own photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'item-photos' and (storage.foldername(name))[1] = auth.uid()::text);
