# Team Compass — preparation files

This folder is **temporary scaffolding** that lives inside the public
`beverage-compass` repository while we wait for the dedicated
`team-compass` **private** repository to be created.

Nothing in this folder contains personal information. When the new private
repo is ready, copy the contents of this folder into it and delete this
folder from `beverage-compass`.

---

## What's inside

```
team-compass-prep/
├── README.md                       (this file)
└── supabase/
    ├── 01_schema.sql               tables, indexes, comments
    ├── 02_rls.sql                  Row Level Security policies
    └── 03_seed_vocabulary.sql      30 sample English words (no PII)
```

---

## What you need to do

### 1. Create the private GitHub repository

1. Go to <https://github.com/new>
2. **Repository name**: `team-compass`
3. **Visibility**: **Private** (this is critical — the app will hold family PII)
4. Tick "Initialize this repository with a README"
5. Create
6. Send me the URL (e.g. `https://github.com/<you>/team-compass`)

### 2. Create the Supabase project

1. Sign in at <https://supabase.com/> (you can use your GitHub account)
2. Click **New project**
3. **Name**: `team-compass` (or anything)
4. **Database password**: generate a strong one and save it somewhere safe
5. **Region**: `Northeast Asia (Tokyo)` for lowest latency from Japan
6. Wait ~2 minutes for provisioning

### 3. Apply the schema

1. In the Supabase dashboard, open **SQL Editor** (left sidebar)
2. Click **New query**
3. Paste the contents of `01_schema.sql` and click **Run**
4. Repeat with `02_rls.sql`
5. Repeat with `03_seed_vocabulary.sql`

You can re-run any of these — they're written to be idempotent.

### 4. Send me these credentials

From the Supabase dashboard, **Settings → API**:

| Item | Safe to share | Where it goes |
|---|---|---|
| Project URL | ✅ yes | frontend env var |
| `anon` / `public` key | ✅ yes | frontend env var |
| `service_role` key | ❌ **never** | backend only, you keep it |

Send me the first two. The third stays with you and only goes into the
backend's environment variables on Vercel later.

---

## Schema summary

| Table | Purpose |
|---|---|
| `families` | One row per household, login by `family_code` |
| `family_members` | People in a family (role, level, emoji, color) |
| `vocabulary_items` | Shared word bank, all families read the same items |
| `vocab_progress` | SRS state per (member, word) — drives "today's 20" |
| `learning_sessions` | One row per practice session |
| `answer_logs` | One row per answered question — drives "mistake review" |
| `daily_stats` | Daily roll-up per member — drives family ranking & streaks |
| `support_messages` | Mother → child cheering messages, "reward box" style |
| `activity_feed` | Family timeline ("〇〇 が 30問正解！") |

All column names are English (snake_case). Comments inside the SQL are
bilingual.

---

## Auth model (MVP)

For the first version we're using **family code login** (no passwords,
just pick a family member). This means:

- The frontend uses Supabase's `anon` key only to read `vocabulary_items`.
- All other reads/writes go through a small backend (Vercel Edge function)
  that holds the `service_role` key and validates the family code.
- RLS policies in `02_rls.sql` deny all anon access to the family-specific
  tables as defense in depth.

When we later move to Supabase Auth (one user per family member, magic
links to the parent), we'll replace the "deny anon" policies with
claim-based ones. There are stub comments in `02_rls.sql` showing the
target shape.

---

## Sensitive data

This scaffolding contains **no real personal information**. When you
populate the app:

- **Family member names** → entered by you in the UI, stored in
  `family_members.display_name`. They never get hard-coded in source.
- **Birthdays** → stored in `family_members.birthdate` if entered.
  Optional.
- **Address / real estate / financial details** → these belong in the
  future **Vault** section, which we'll design separately with proper
  encryption (likely using a library like `libsodium` and a master
  passphrase that never leaves your device). The Vault is **not** part
  of the MVP and will not store real data until that design is
  reviewed.
- **Passwords for other services** → same as above, Vault only, with
  client-side encryption.

If you ever feel an urge to paste a real password or a bank account
number into a chat, stop and think about whether the conversation is
private. (Source code, public chats, screenshots — all bad.)
