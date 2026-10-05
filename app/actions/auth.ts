"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getSiteUrl } from "@/lib/site";

export type AuthState = { error?: string; notice?: string; email?: string; dealerName?: string };

function safeNext(next: string): string {
  return next.startsWith("/") && !next.startsWith("//") ? next : "/inventory";
}

export async function login(_prev: AuthState, formData: FormData): Promise<AuthState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  if (!email || !password) return { error: "Enter your email and password.", email };

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) {
    const message = /invalid login/i.test(error.message)
      ? "That email and password do not match an account."
      : /not confirmed/i.test(error.message)
        ? "Confirm your email first. The link is in the message Chopmark sent you."
        : error.message;
    return { error: message, email };
  }
  redirect(safeNext(String(formData.get("next") ?? "")));
}

export async function signup(_prev: AuthState, formData: FormData): Promise<AuthState> {
  const dealerName = String(formData.get("dealer_name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const keep = { email, dealerName };

  if (!dealerName) return { error: "Enter your business or dealer name.", ...keep };
  if (!email) return { error: "Enter your email.", ...keep };
  if (password.length < 8) return { error: "Use a password of at least 8 characters.", ...keep };

  const supabase = await createClient();
  const siteUrl = await getSiteUrl();
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { dealer_name: dealerName }, emailRedirectTo: `${siteUrl}/auth/callback` },
  });
  if (error) {
    return { error: /already registered/i.test(error.message) ? "That email already has an account. Log in instead." : error.message, ...keep };
  }
  if (!data.session) {
    return { notice: "Account created. Open the confirmation link we emailed you, then log in.", ...keep };
  }
  redirect("/inventory?welcome=1");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}
