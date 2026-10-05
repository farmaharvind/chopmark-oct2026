import { cache } from "react";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import type { Dealer } from "@/lib/types";

/** The signed-in dealer, or null. Cached for the length of one request. */
export const getDealer = cache(async (): Promise<Dealer | null> => {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;
  const { data } = await supabase
    .from("dealers")
    .select("id,name,slug,created_at")
    .eq("id", user.id)
    .maybeSingle();
  return (data as Dealer | null) ?? null;
});

export async function requireDealer(): Promise<Dealer> {
  const dealer = await getDealer();
  // "missing" stops proxy.ts from bouncing a signed-in user straight back here.
  if (!dealer) redirect("/login?missing=dealer");
  return dealer;
}
