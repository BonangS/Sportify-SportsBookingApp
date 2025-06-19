-- SQL Query for creating notifications table in Supabase

create table public.notifications (
  id uuid not null primary key,
  user_id uuid not null references auth.users,
  title text not null,
  message text not null,
  type text not null,
  booking_id uuid references public.bookings,
  timestamp timestamptz not null default now(),
  is_read boolean not null default false
);

-- Add RLS (Row Level Security) policies
alter table public.notifications enable row level security;

-- Policy to allow users to see only their own notifications
create policy "Users can view their own notifications" on public.notifications
  for select using (auth.uid() = user_id);

-- Policy to allow authenticated users to insert their own notifications
create policy "Users can insert their own notifications" on public.notifications
  for insert with check (auth.uid() = user_id);

-- Policy to allow users to update only their own notifications (for marking as read)
create policy "Users can update their own notifications" on public.notifications
  for update using (auth.uid() = user_id);

-- Add indexes for better performance
create index notifications_user_id_idx on public.notifications(user_id);
create index notifications_timestamp_idx on public.notifications(timestamp);
create index notifications_is_read_idx on public.notifications(is_read);
