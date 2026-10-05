# Chopmark

Tag it. Track it. Trust it. Each collectible gets a permanent ID (GOID) and a public page reached by QR code or NFC tag.

**This is Phase 1 (the core loop).** Phases 2 to 4 are not built yet.

Stack: Next.js 16 (App Router), Tailwind 4, Supabase (Postgres, auth, storage), deployed on Vercel.

## Set up and deploy (about 15 minutes)

You need three free accounts: **Supabase**, **GitHub**, **Vercel**. An Anthropic key is not needed until Phase 4.

### 1. Supabase

1. At supabase.com create a new project. Save the database password somewhere; the app does not need it.
2. Open **SQL Editor**. Paste all of `supabase/schema.sql` and press **Run**.
3. New query. Paste all of `supabase/seed.sql` and press **Run**. This adds two demo dealers and 34 items.
4. Open **Authentication > Sign In / Providers > Email** and turn **Confirm email** off, then save. With it on, a new dealer has to click an emailed link before logging in, and the free plan only sends a few emails an hour.
5. Press **Connect** at the top of the project page (or open **Settings > API Keys**) and copy two values: the **Project URL** and the **publishable key** (`sb_publishable_...`).

### 2. GitHub

Create a new private repository and put the contents of this folder in it. Without a terminal: on the new repo page choose "uploading an existing file" and drag everything in. With a terminal:

```
git init && git add -A && git commit -m "Chopmark phase 1"
git remote add origin https://github.com/YOU/chopmark.git && git push -u origin main
```

### 3. Vercel

1. At vercel.com choose **Add New > Project** and import the repository.
2. Before deploying, open **Environment Variables** and add:

   | Name | Value |
   | --- | --- |
   | `NEXT_PUBLIC_SUPABASE_URL` | the Project URL from step 1.5 |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | the publishable key from step 1.5 |

3. Press **Deploy**. If you add or change a variable later, redeploy, because these two are read at build time.

QR codes and NFC links use the project's production address automatically. If you attach a custom domain, add `NEXT_PUBLIC_SITE_URL` (for example `https://chopmark.com`) and redeploy, then reprint labels.

### 4. Demo logins

| Email | Password | Dealer |
| --- | --- | --- |
| `halvorsen@example.com` | `chopmark-demo` | Halvorsen Coin & Stamp (coins, stamps) |
| `thirdrail@example.com` | `chopmark-demo` | Third Rail Collectibles (cards, comics) |

These passwords are in this file, so anyone who has the repo can log in as the demo dealers. Run `supabase/seed.sql` again to reset them, or delete the two users under **Authentication > Users** before sharing the site widely.

## Run it on your own computer

```
npm install
cp .env.example .env.local    # then fill in the two Supabase values
npm run dev                   # http://localhost:3000
```

## What to test (Phase 1)

1. **Sign up** at `/signup` with a new dealer name. You should land on an empty inventory.
2. **Add an item** with two photos from your phone. Saving should show its GOID, QR code and history ("Tagged and added to inventory").
3. **Edit** the price and save. The history should gain "Price changed to ...". Add a note; it appears in the history.
4. **Inventory**: search by name and by part of a GOID, filter by category and status, press **Mark sold**. Sold items show "Back in stock".
5. **Public page**: scan the QR code on screen with your phone camera. It should open `/i/GOID` with photos, price, dealer and history, without logging in.
6. **Labels**: tick two items, press **Print labels**, print on plain paper at 100% scale and hold it against a sticker sheet. Copy an NFC link.
7. **Isolation**: log in as one demo dealer and confirm the other dealer's items are not in the inventory.

## How it is organised

```
app/
  page.tsx                 home page
  login, signup            dealer accounts
  (dealer)/inventory       list, add item, edit item
  (dealer)/labels          QR sticker sheets and NFC links
  i/[goid]                 the public item page
  actions/                 everything that writes to the database
components/                form, timeline, ID plate, drawings for items with no photo
lib/                       Supabase clients, formatting, QR, types
proxy.ts                   keeps the login fresh, guards the dealer screens
supabase/schema.sql        tables, security rules, history triggers
supabase/seed.sql          demo data
```

History is written by a database trigger (`log_item_event` in `schema.sql`), not by the app, so every price or status change is recorded however it happens, and dealers cannot edit or delete it.
