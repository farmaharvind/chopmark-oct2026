import Link from "next/link";
import { signOut } from "@/app/actions/auth";
import { DealerNav } from "@/components/DealerNav";
import { Wordmark } from "@/components/Mark";
import { requireDealer } from "@/lib/dealer";

export default async function DealerLayout({ children }: { children: React.ReactNode }) {
  const dealer = await requireDealer();
  return (
    <>
      <header className="no-print bg-gunmetal text-pewter">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center gap-x-4 gap-y-2 px-4 py-2.5">
          <Link href="/inventory" aria-label="Chopmark inventory"><Wordmark /></Link>
          <DealerNav />
          <div className="ml-auto flex items-center gap-3">
            <span className="hidden text-sm text-pewter/80 md:inline">{dealer.name}</span>
            <form action={signOut}>
              <button className="rounded-[3px] px-2 py-1.5 text-sm font-semibold text-pewter hover:bg-gunmetal-soft">Sign out</button>
            </form>
          </div>
        </div>
      </header>
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-6 print:max-w-none print:p-0">{children}</main>
    </>
  );
}
