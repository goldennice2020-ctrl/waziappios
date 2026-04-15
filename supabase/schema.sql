create extension if not exists "pgcrypto";

create table if not exists public.orders (
    id uuid primary key default gen_random_uuid(),
    order_number text not null unique,
    product_name text not null,
    color text not null check (color in ('black', 'white', 'gray')),
    amount integer not null check (amount > 0),
    pack_description text not null,
    payment_state text not null check (payment_state in ('待人工确认', '已支付')),
    shipping_state text not null check (shipping_state in ('待处理', '未填写地址', '待发货', '已发货')),
    receiver_name text,
    receiver_phone text,
    receiver_address text,
    tracking_number text,
    created_at timestamptz not null default timezone('utc', now())
);

create index if not exists orders_created_at_idx on public.orders (created_at desc);
create index if not exists orders_shipping_state_idx on public.orders (shipping_state);

alter table public.orders enable row level security;

drop policy if exists "public can read orders" on public.orders;
create policy "public can read orders"
on public.orders
for select
using (true);

drop policy if exists "public can insert orders" on public.orders;
create policy "public can insert orders"
on public.orders
for insert
with check (true);

drop policy if exists "public can update orders" on public.orders;
create policy "public can update orders"
on public.orders
for update
using (true)
with check (true);
