import type { Metadata } from "next";
import { AuthForm } from "@/components/AuthForm";
import { AuthShell } from "@/components/AuthShell";

export const metadata: Metadata = { title: "Log in" };

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ next?: string; missing?: string }> }) {
  const { next, missing } = await searchParams;
  return (
    <AuthShell title="Log in">
      {missing && (
        <p role="alert" className="mb-4 rounded-[3px] border border-alert bg-white px-3 py-2 text-sm font-medium text-alert">
          This login has no dealer profile. Run supabase/schema.sql again in the Supabase SQL editor, then log in.
        </p>
      )}
      <AuthForm mode="login" next={next ?? ""} />
    </AuthShell>
  );
}
