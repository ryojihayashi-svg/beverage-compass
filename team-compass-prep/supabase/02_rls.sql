-- ============================================================================
-- Row Level Security policies
--
-- Auth model assumed (MVP):
--   - Frontend never talks to Supabase directly with the service_role key.
--   - A small backend (Vercel Edge / Cloud Function) holds service_role and
--     proxies all writes after validating a family_code + member selection.
--   - The anon key is used only for: read of vocabulary_items + audio files.
--
-- These RLS policies act as defense-in-depth. The backend is the trust boundary.
-- When we later switch to Supabase Auth, replace the policies below with
-- ones that read auth.uid() and an "app_metadata.family_id" claim.
-- ============================================================================

-- Enable RLS on every table
alter table families         enable row level security;
alter table family_members   enable row level security;
alter table vocabulary_items enable row level security;
alter table vocab_progress   enable row level security;
alter table learning_sessions enable row level security;
alter table answer_logs      enable row level security;
alter table daily_stats      enable row level security;
alter table support_messages enable row level security;
alter table activity_feed    enable row level security;

-- ----------------------------------------------------------------------------
-- vocabulary_items: public read of active items
--                   全家族で共有する語彙バンクは anon でも読める
-- ----------------------------------------------------------------------------
drop policy if exists vocab_public_read on vocabulary_items;
create policy vocab_public_read
  on vocabulary_items
  for select
  to anon, authenticated
  using (is_active = true);

-- ----------------------------------------------------------------------------
-- All other tables: deny anon entirely.
-- service_role bypasses RLS automatically, so the backend can read/write.
-- 認証モデルが決まるまでは anon からの直接アクセスは全拒否。
-- ----------------------------------------------------------------------------
-- families
drop policy if exists families_no_anon on families;
create policy families_no_anon on families for all to anon using (false) with check (false);

-- family_members
drop policy if exists members_no_anon on family_members;
create policy members_no_anon on family_members for all to anon using (false) with check (false);

-- vocab_progress
drop policy if exists progress_no_anon on vocab_progress;
create policy progress_no_anon on vocab_progress for all to anon using (false) with check (false);

-- learning_sessions
drop policy if exists sessions_no_anon on learning_sessions;
create policy sessions_no_anon on learning_sessions for all to anon using (false) with check (false);

-- answer_logs
drop policy if exists answers_no_anon on answer_logs;
create policy answers_no_anon on answer_logs for all to anon using (false) with check (false);

-- daily_stats
drop policy if exists stats_no_anon on daily_stats;
create policy stats_no_anon on daily_stats for all to anon using (false) with check (false);

-- support_messages
drop policy if exists support_no_anon on support_messages;
create policy support_no_anon on support_messages for all to anon using (false) with check (false);

-- activity_feed
drop policy if exists feed_no_anon on activity_feed;
create policy feed_no_anon on activity_feed for all to anon using (false) with check (false);

-- ============================================================================
-- Future (Phase 2): when we adopt Supabase Auth, replace the "no_anon"
-- policies above with claim-based ones, e.g.:
--
--   create policy members_in_my_family on family_members
--     for select to authenticated
--     using (family_id = (auth.jwt() ->> 'family_id')::uuid);
--
-- Remember to also write WITH CHECK clauses on inserts/updates.
-- ============================================================================
