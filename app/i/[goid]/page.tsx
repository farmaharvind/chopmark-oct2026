import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { GoidPlate } from "@/components/GoidPlate";
import { ItemImage } from "@/components/ItemImage";
import { LocalDate } from "@/components/LocalDate";
import { Wordmark } from "@/components/Mark";
import { StatusBadge } from "@/components/StatusBadge";
import { Timeline } from "@/components/Timeline";
import { getDealer } from "@/lib/dealer";
import { CATEGORY_LABEL, money, normalizeGoid } from "@/lib/format";
import { createClient } from "@/lib/supabase/server";
import type { Dealer, Item, ItemEvent } from "@/lib/types";

type Props = { params: Promise<{ goid: string }> };

async function loadItem(rawGoid: string) {
  const goid = normalizeGoid(rawGoid);
  if (goid.length !== 8) return null;
  const supabase = await createClient();
  const { data } = await supabase.from("items").select("*").eq("goid", goid).maybeSingle();
  return (data as Item | null) ?? null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const item = await loadItem((await params).goid);
  if (!item) return { title: "Item not found" };
  return {
    title: `${item.name} (${item.goid})`,
    description: `${CATEGORY_LABEL[item.category]}. ${item.condition ? item.condition + ". " : ""}Chopmark ID ${item.goid}. See this item's price and full history.`,
    openGraph: { images: item.photos?.[0] ? [item.photos[0]] : undefined },
  };
}

export default async function PublicItemPage({ params }: Props) {
  const item = await loadItem((await params).goid);
  if (!item) notFound();

  const supabase = await createClient();
  const [{ data: dealerRow }, { data: eventRows }, viewer] = await Promise.all([
    supabase.from("dealers").select("id,name,slug,created_at").eq("id", item.dealer_id).maybeSingle(),
    supabase
      .from("events")
      .select("id,item_id,type,detail,note,created_at")
      .eq("item_id", item.id)
      .order("created_at", { ascending: false })
      .order("id", { ascending: false }),
    getDealer(),
  ]);
  const dealer = dealerRow as Dealer | null;
  const events = (eventRows ?? []) as ItemEvent[];
  const isOwner = viewer?.id === item.dealer_id;
  const sold = item.status === "sold";

  return (
    <>
      <header className="bg-gunmetal text-pewter">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-2.5">
          <Link href="/" aria-label="Chopmark home"><Wordmark /></Link>
          {isOwner ? (
            <Link href={`/inventory/${item.goid}`} className="rounded-[3px] border border-pewter/50 px-2.5 py-1 text-sm font-semibold hover:bg-gunmetal-soft">Edit this item</Link>
          ) : (
            <span className="text-sm text-pewter/75">Item record</span>
          )}
        </div>
      </header>

      <main className="mx-auto w-full max-w-5xl flex-1 md:grid md:grid-cols-[minmax(0,1.05fr)_minmax(0,1fr)] md:gap-8 md:px-4 md:py-8">
        <section aria-label="Photos" className="md:sticky md:top-6 md:self-start">
          {item.photos.length > 1 ? (
            <>
              <div className="flex snap-x snap-mandatory overflow-x-auto md:rounded-[4px] md:border md:border-line">
                {item.photos.map((photo, index) => (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img key={photo} src={photo} alt={`${item.name}, photo ${index + 1} of ${item.photos.length}`} className="aspect-square w-full shrink-0 snap-center object-cover" loading={index === 0 ? "eager" : "lazy"} />
                ))}
              </div>
              <p className="px-4 pt-2 text-sm text-ink-soft md:px-0">{item.photos.length} photos. Swipe to see them all.</p>
            </>
          ) : (
            <div className="overflow-hidden md:rounded-[4px] md:border md:border-line">
              <ItemImage photo={item.photos[0]} category={item.category} goid={item.goid} alt={item.name} className={`w-full ${item.photos[0] ? "aspect-square" : "aspect-[2/1] md:aspect-square"}`} />
            </div>
          )}
        </section>

        <div className="px-4 pb-10 pt-5 md:p-0">
          <div className="flex flex-wrap items-center gap-2.5">
            <StatusBadge status={item.status} large />
            <span className="text-sm text-ink-soft">{CATEGORY_LABEL[item.category]}</span>
          </div>

          <h1 className="display mt-3 text-[1.75rem] sm:text-4xl">{item.name}</h1>

          <div className="mt-4 flex flex-wrap items-end justify-between gap-x-6 gap-y-3">
            <div>
              <p className="text-sm text-ink-soft">{sold ? "Last asking price" : "Price"}</p>
              <p className={`font-mono text-3xl font-medium ${sold ? "text-ink-soft line-through decoration-1" : ""}`}>{money(item.price)}</p>
            </div>
            <GoidPlate goid={item.goid} size="md" />
          </div>

          <dl className="mt-6 divide-y divide-line border-y border-line">
            {item.condition && (
              <div className="grid grid-cols-[7.5rem_1fr] gap-3 py-2.5">
                <dt className="text-sm text-ink-soft">Condition</dt>
                <dd className="font-medium">{item.condition}</dd>
              </div>
            )}
            <div className="grid grid-cols-[7.5rem_1fr] gap-3 py-2.5">
              <dt className="text-sm text-ink-soft">Tagged</dt>
              <dd className="font-medium"><LocalDate iso={item.created_at} /></dd>
            </div>
            {sold && item.sold_at && (
              <div className="grid grid-cols-[7.5rem_1fr] gap-3 py-2.5">
                <dt className="text-sm text-ink-soft">Sold</dt>
                <dd className="font-medium"><LocalDate iso={item.sold_at} /></dd>
              </div>
            )}
            {dealer && (
              <div className="grid grid-cols-[7.5rem_1fr] gap-3 py-2.5">
                <dt className="text-sm text-ink-soft">{sold ? "Tagged by" : "Dealer"}</dt>
                <dd>
                  <span className="font-medium">{dealer.name}</span>
                  <span className="block text-sm text-ink-soft">On Chopmark since <LocalDate iso={dealer.created_at} /></span>
                </dd>
              </div>
            )}
          </dl>

          {item.notes && (
            <section className="mt-6">
              <h2 className="font-semibold">Dealer&rsquo;s notes</h2>
              <p className="mt-1.5 max-w-[60ch] whitespace-pre-line">{item.notes}</p>
            </section>
          )}

          <section className="mt-8">
            <h2 className="display text-xl">History</h2>
            <p className="hint mb-4 mt-1">Recorded when each change happened. Entries cannot be edited or removed.</p>
            <Timeline events={events} />
          </section>

          <p className="mt-10 border-t border-line pt-4 text-sm text-ink-soft">
            Every item tagged with Chopmark has a permanent ID and a public record. Scanning its tag always opens this page.
          </p>
        </div>
      </main>
    </>
  );
}
