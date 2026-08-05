# SplitCrew

Split bills and track shared expenses with your crew — no signup, no app download.
Create a crew, log what everyone spent on your outing, and SplitCrew works out
who owes who and the fewest payments needed to settle up.

Live at: **splitcrew.in**

---

## How it's built

A single static `index.html` — no build tooling, no framework, no server. Data
is stored in [Supabase](https://supabase.com) (Postgres) through a locked-down
API. There is no login system; a crew's code (or its share link) *is* the
access control, the same way a shared document link works.

**No secrets live in this repository.** The `SUPABASE_URL` and `SUPABASE_ANON_KEY`
in `index.html` are placeholder tokens (`__SUPABASE_URL__`, `__SUPABASE_ANON_KEY__`)
swapped for real values at deploy time by Cloudflare Pages, using environment
variables stored only in Cloudflare's dashboard. Nothing sensitive ever touches
git history.

(Side note on why that's safe either way: Supabase's anon key is *designed* to
be public-facing — it's not a password. The actual security boundary is
`schema.sql`, which only allows fetching one exact key at a time through two
narrow database functions, with the raw table locked from direct access
entirely. Never add a `service_role` key anywhere in this project — that one
bypasses everything and must stay truly secret.)

---

## First-time setup

### 1. Database (Supabase)
1. Create a free project at supabase.com.
2. Project → **SQL Editor → New query** → paste the entire contents of
   `schema.sql` → **Run**.
3. Project → **Settings → API** → copy the **Project URL** and **anon public** key.
   You'll paste these into Cloudflare in step 3 below, not into any file here.

### 2. Push this repo to GitHub
```bash
git init
git add .
git commit -m "Initial SplitCrew site"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/splitcrew.git
git push -u origin main
```

### 3. Connect Cloudflare Pages
1. pages.cloudflare.com → **Create a project → Connect to Git** → pick this repo.
2. **Build command:**
   ```
   sh -c "sed -i \"s|__SUPABASE_URL__|$SUPABASE_URL|g; s|__SUPABASE_ANON_KEY__|$SUPABASE_ANON_KEY|g\" index.html"
   ```
3. **Build output directory:** `/`
4. Before deploying, go to **Settings → Environment variables** and add:
   - `SUPABASE_URL` = (the Project URL from step 1)
   - `SUPABASE_ANON_KEY` = (the anon public key from step 1)

   Tick **"Encrypt"** on both if offered — keeps them hidden even from your own
   dashboard view after saving.
5. Deploy. Cloudflare pulls the repo, runs the substitution, and publishes the
   result — the real keys exist only in that build step and in Cloudflare's
   encrypted settings, never in GitHub.

### 4. Connect the domain
Custom domains → add `splitcrew.in`. See the DNS notes below if the domain is
registered elsewhere (e.g. HostingRaja) — you only need to point its
nameservers at Cloudflare once; Cloudflare handles the rest automatically.

---

## Making changes after launch

Edit any file in this repo (even directly in GitHub's web editor) → commit to
`main` → Cloudflare rebuilds and redeploys automatically, live in under a
minute. No manual upload, ever.

---

## Files in this repo

| File | Purpose |
|---|---|
| `index.html` | The app |
| `schema.sql` | Run once in Supabase's SQL Editor to set up the database |
| `privacy.html` | Linked from the app footer |
| `robots.txt`, `sitemap.xml` | Search engine crawling config |
| `og-image.png` | Link preview image (WhatsApp, Slack, iMessage, etc.) |

The domain is already set to `splitcrew.in` throughout `index.html`,
`robots.txt`, and `sitemap.xml` — no placeholder cleanup needed.
