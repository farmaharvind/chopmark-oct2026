import Link from "next/link";
import { GoidPlate } from "@/components/GoidPlate";
import { ItemImage } from "@/components/ItemImage";
import { Wordmark } from "@/components/Mark";
import { getDealer } from "@/lib/dealer";
import { CATEGORY_LABEL, money } from "@/lib/format";
import { qrSvg } from "@/lib/qr";
import { getSiteUrl, itemUrl } from "@/lib/site";
import { createClient } from "@/lib/supabase/server";
import type { Item } from "@/lib/types";

type Listed = Pick<Item, "id" | "goid" | "dealer_id" | "name" | "category" | "price" | "condition" | "photos">;

const STEPS = [
  {
    shape: "square",
    title: "Tag it",
    body: "Add the item and Chopmark assigns it a permanent ID. Print the QR label or write the link to an NFC tag.",
  },
  {
    shape: "circle",
    title: "Track it",
    body: "Every price change, hold and sale is recorded with its date and time. The record cannot be edited.",
  },
  {
    shape: "hexagon",
    title: "Trust it",
    body: "A buyer scans the tag and reads the item's details, price and full history before they pay.",
  },
] as const;

function Punch({ shape }: { shape: "square" | "circle" | "hexagon" }) {
  return (
    <svg width="28" height="28" viewBox="0 0 24 24" aria-hidden="true" className="text-brass">
      {shape === "square" && <rect x="4" y="4" width="16" height="16" fill="currentColor" />}
      {shape === "circle" && <circle cx="12" cy="12" r="9" fill="currentColor" />}
      {shape === "hexagon" && <path fill="currentColor" d="m12 2.5 8.2 4.75v9.5L12 21.5l-8.2-4.75v-9.5L12 2.5Z" />}
    </svg>
  );
}

export default async function HomePage() {
  const supabase = await createClient();
  const [{ data }, dealer, siteUrl] = await Promise.all([
    supabase
      .from("items")
      .select("id,goid,dealer_id,name,category,price,condition,photos")
      .eq("status", "in_stock")
      .order("created_at", { ascending: false })
      .limit(7),
    getDealer(),
    getSiteUrl(),
  ]);
  const items = (data ?? []) as Listed[];
  const sample = items[0];
  const recent = items.slice(1, 7);
  const sampleQr = sample ? await qrSvg(itemUrl(siteUrl, sample.goid)) : null;

  return (
    <>
      <div className="bg-gunmetal text-pewter">
        <header className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
          <Wordmark />
          <nav className="flex items-center gap-2" aria-label="Account">
            {dealer ? (
              <Link href="/inventory" className="btn btn-primary !min-h-9">Open inventory</Link>
            ) : (
              <>
                <Link href="/login" className="rounded-[3px] px-3 py-2 text-sm font-semibold hover:bg-gunmetal-soft">Log in</Link>
                <Link href="/signup" className="btn btn-primary !min-h-9">Create dealer account</Link>
              </>
            )}
          </nav>
        </header>

        <section className="mx-auto grid max-w-6xl gap-10 px-4 pb-14 pt-8 md:grid-cols-[minmax(0,1.15fr)_minmax(0,0.85fr)] md:items-center md:pb-20 md:pt-14">
          <div>
            <h1 className="display text-[clamp(2.6rem,9vw,5.25rem)] leading-[0.98]">
              Tag it.<br />Track it.<br />Trust it.
            </h1>
            <p className="mt-6 max-w-[34rem] text-lg text-pewter/90">
              Chopmark gives each collectible a permanent ID and a public page. Dealers tag inventory at the table. Buyers scan the tag to see the item, its price and everything that has happened to it.
            </p>
            <div className="mt-7 flex flex-wrap gap-3">
              <Link href={dealer ? "/inventory" : "/signup"} className="btn btn-primary">{dealer ? "Open inventory" : "Start tagging"}</Link>
              {sample && (
                <Link href={`/i/${sample.goid}`} className="btn !border-pewter !text-pewter hover:!bg-pewter hover:!text-gunmetal">See a tagged item</Link>
              )}
            </div>
          </div>

          {sample && sampleQr && (
            <Link href={`/i/${sample.goid}`} className="group block justify-self-center md:justify-self-end" aria-label={`Open the record for ${sample.name}`}>
              <div className="w-[min(21rem,100%)] rounded-[6px] bg-white p-5 text-gunmetal shadow-[6px_6px_0_var(--color-brass)]">
                <div className="flex gap-4">
                  <div className="h-28 w-28 shrink-0 text-black" dangerouslySetInnerHTML={{ __html: sampleQr }} />
                  <div className="min-w-0">
                    <p className="line-clamp-3 font-semibold leading-snug">{sample.name}</p>
                    {sample.condition && <p className="mt-1 text-sm text-ink-soft">{sample.condition}</p>}
                    <p className="mt-1 font-mono text-lg font-medium">{money(sample.price)}</p>
                  </div>
                </div>
                <div className="mt-4 flex items-center justify-between gap-3 border-t border-line pt-3">
                  <GoidPlate goid={sample.goid} size="sm" />
                  <span className="text-sm font-semibold underline-offset-3 group-hover:underline">Scan it, or open the record</span>
                </div>
              </div>
            </Link>
          )}
        </section>
      </div>

      <main className="mx-auto w-full max-w-6xl flex-1 px-4">
        <ol className="grid gap-8 py-12 md:grid-cols-3 md:gap-10">
          {STEPS.map((step) => (
            <li key={step.title}>
              <Punch shape={step.shape} />
              <h2 className="display mt-3 text-2xl">{step.title}</h2>
              <p className="mt-2 max-w-[38ch] text-ink-soft">{step.body}</p>
            </li>
          ))}
        </ol>

        {recent.length > 0 && (
          <section className="border-t border-line py-12">
            <h2 className="display text-2xl">Recently tagged</h2>
            <ul className="mt-6 grid grid-cols-2 gap-x-4 gap-y-7 md:grid-cols-3 lg:grid-cols-6">
              {recent.map((item) => (
                <li key={item.id}>
                  <Link href={`/i/${item.goid}`} className="group block">
                    <div className="overflow-hidden rounded-[3px] border border-line">
                      <ItemImage photo={item.photos?.[0]} category={item.category} goid={item.goid} alt="" className="aspect-square w-full" />
                    </div>
                    <p className="mt-2 line-clamp-2 text-[0.9375rem] font-semibold leading-snug group-hover:underline">{item.name}</p>
                    <p className="mt-1 text-sm text-ink-soft">{CATEGORY_LABEL[item.category]}</p>
                    <p className="mt-0.5 flex items-baseline justify-between gap-2">
                      <span className="font-mono text-[0.9375rem] font-medium">{money(item.price)}</span>
                      <span className="goid text-xs text-ink-soft">{item.goid}</span>
                    </p>
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}
      </main>

      <footer className="border-t border-line">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-5 text-sm text-ink-soft">
          <Wordmark className="text-gunmetal" />
          <p>A permanent ID and public history for coins, cards, comics, stamps, watches and art.</p>
        </div>
      </footer>
    </>
  );
}
