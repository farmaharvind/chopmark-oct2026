import { Mark } from "@/components/Mark";

export function SetupNotice() {
  return (
    <main className="mx-auto max-w-xl px-5 py-16">
      <Mark size={36} />
      <h1 className="display mt-6 text-3xl">Chopmark is not connected to a database yet</h1>
      <p className="mt-4">
        Add these two environment variables in Vercel (Project, Settings, Environment Variables), then redeploy:
      </p>
      <ul className="mt-4 space-y-2 font-mono text-sm">
        <li>NEXT_PUBLIC_SUPABASE_URL</li>
        <li>NEXT_PUBLIC_SUPABASE_ANON_KEY</li>
      </ul>
      <p className="mt-4 hint">Both values are on the Supabase project page under Connect. SETUP.md has the full steps.</p>
    </main>
  );
}
