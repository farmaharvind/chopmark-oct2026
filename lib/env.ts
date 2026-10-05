export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
// Either the "anon" key or the newer "publishable" key works here.
export const SUPABASE_KEY =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ??
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ??
  "";
export const isConfigured = Boolean(SUPABASE_URL && SUPABASE_KEY);
export const PHOTO_BUCKET = "item-photos";
