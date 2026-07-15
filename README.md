# DaySol Baseline Survey

12-question US K-beauty consumer survey, chunked into a short 6-screen flow
(see `../daysol_screener_spec_v2.md` for the full design spec). Built with
Next.js + Supabase, deployable to Vercel.

## What you need to do (nothing here requires touching code)

### 1. Create a Supabase project (~2 minutes)
1. Go to https://supabase.com → sign up (free) → "New project".
2. Pick any name/region, set a database password (save it somewhere), wait
   ~1 minute for it to provision.
3. In the left sidebar, go to **SQL Editor** → **New query**.
4. Open `supabase_setup.sql` from this folder, paste its contents in, click
   **Run**. This creates the `screeners` table and lets the app read/write
   to it.
5. In the left sidebar, go to **Project Settings → API**. Copy two values:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **anon public** key (a long string under "Project API keys")

   Keep this tab open — you'll paste these into Vercel in step 3.

### 2. Push this code to GitHub
1. Go to https://github.com/new → create a new **empty** repository (no
   README/license, since this folder already has them) — call it
   `daysol-survey` or whatever you like.
2. On your own machine, in a terminal, inside this project folder:
   ```
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add originhttps://github.com/jinssool/daysol_survey.git
   git push -u origin main
   ```
   (Replace the URL with the one GitHub shows you after creating the repo.)

### 3. Import into Vercel and deploy
1. Go to https://vercel.com → sign in with your GitHub account.
2. Click **Add New → Project**, select the `daysol-survey` repo you just
   pushed, click **Import**.
3. Before clicking Deploy, expand **Environment Variables** and add:
   | Name | Value |
   |---|---|
   | `NEXT_PUBLIC_SUPABASE_URL` | the Project URL from step 1.5 |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | the anon public key from step 1.5 |
4. Click **Deploy**. Takes about a minute. You'll get a live URL like
   `daysol-survey.vercel.app`.

That's it — every future `git push` to `main` auto-redeploys.

## Local development (optional)
```
npm install
cp .env.local.example .env.local   # then fill in your Supabase values
npm run dev
```
Open http://localhost:3000

## Notes
- The contact-card image shown after saving lives at `public/contact-card.jpg`
  — swap this file for an updated version any time, no code changes needed.
- The Supabase table has no auth — anyone with the anon key (which is
  public/embedded in the deployed site by design) can read/write. Fine for a
  short field survey; see `supabase_setup.sql` comments if you want to lock
  it down later.
- Full content/design spec: see the accompanying `daysol_screener_spec_v2.md`.
