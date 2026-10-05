import Link from "next/link";
import { Wordmark } from "@/components/Mark";

export function AuthShell({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <main className="mx-auto w-full max-w-md px-5 py-10 sm:py-16">
      <Link href="/" aria-label="Chopmark home"><Wordmark /></Link>
      <h1 className="display mt-8 text-3xl">{title}</h1>
      <div className="panel mt-6 p-5">{children}</div>
    </main>
  );
}
