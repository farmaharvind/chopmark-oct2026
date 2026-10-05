import type { Metadata } from "next";
import Link from "next/link";
import { CopyButton } from "@/components/CopyButton";
import { AutoSubmitForm, DownloadCsvButton, PrintButton } from "@/components/LabelControls";
import { Mark } from "@/components/Mark";
import { requireDealer } from "@/lib/dealer";
import { money, normalizeGoid, splitGoid } from "@/lib/format";
import { qrSvg } from "@/lib/qr";
import { getSiteUrl, itemUrl } from "@/lib/site";
import { createClient } from "@/lib/supabase/server";
import type { Item } from "@/lib/types";

export const metadata: Metadata = { title: "Labels" };

const LAYOUTS = {
  "30": { perSheet: 30, name: "Small, 30 per sheet (1 x 2 5/8 in, Avery 5160)" },
  "10": { perSheet: 10, name: "Large, 10 per sheet (2 x 4 in, Avery 5163)" },
} as const;
type LayoutKey = keyof typeof LAYOUTS;

type Search = { g?: string | string[]; layout?: string; price?: string; skip?: string };
type LabelItem = Pick<Item, "id" | "goid" | "name" | "price" | "condition"> & { url: string; qr: string };

export default async function LabelsPage({ searchParams }: { searchParams: Promise<Search> }) {
  const dealer = await requireDealer();
  const params = await searchParams;
  const goids = (Array.isArray(params.g) ? params.g : params.g ? [params.g] : []).map(normalizeGoid).filter((g) => g.length === 8).slice(0, 300);
  const layout: LayoutKey = params.layout === "10" ? "10" : "30";
  const showPrice = params.price === "1";
  const perSheet = LAYOUTS[layout].perSheet;
  const skip = Math.min(Math.max(parseInt(params.skip ?? "0", 10) || 0, 0), perSheet - 1);

  const supabase = await createClient();
  let query = supabase
    .from("items")
    .select("id,goid,name,price,condition")
    .eq("dealer_id", dealer.id)
    .order("created_at", { ascending: false })
    .limit(300);
  query = goids.length ? query.in("goid", goids) : query.eq("status", "in_stock");
  const { data } = await query;

  const siteUrl = await getSiteUrl();
  const items: LabelItem[] = await Promise.all(
    ((data ?? []) as Pick<Item, "id" | "goid" | "name" | "price" | "condition">[]).map(async (item) => {
      const url = itemUrl(siteUrl, item.goid);
      return { ...item, url, qr: await qrSvg(url) };
    })
  );

  // Blank cells first, so a part-used sticker sheet can go back in the printer.
  const cells: (LabelItem | null)[] = [...Array<null>(skip).fill(null), ...items];
  const sheets: (LabelItem | null)[][] = [];
  for (let i = 0; i < cells.length; i += perSheet) sheets.push(cells.slice(i, i + perSheet));

  return (
    <div>
      <div className="no-print space-y-5">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <h1 className="display text-3xl">Labels</h1>
            <p className="hint mt-1">
              {items.length} {items.length === 1 ? "label" : "labels"}
              {goids.length ? " for the items you picked" : " for everything in stock"}.{" "}
              {goids.length > 0 && <Link className="link" href="/labels">Show all in-stock items</Link>}
            </p>
          </div>
          <PrintButton disabled={items.length === 0} />
        </div>

        <AutoSubmitForm action="/labels" className="panel grid gap-4 p-4 sm:grid-cols-[minmax(0,1fr)_auto_auto] sm:items-end">
          {goids.map((g) => (
            <input key={g} type="hidden" name="g" value={g} />
          ))}
          <div>
            <label className="label" htmlFor="layout">Sticker sheet</label>
            <select className="field" id="layout" name="layout" defaultValue={layout}>
              {(Object.keys(LAYOUTS) as LayoutKey[]).map((key) => (
                <option key={key} value={key}>{LAYOUTS[key].name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="label" htmlFor="skip">Stickers already used</label>
            <input className="field sm:w-36" id="skip" name="skip" type="number" min={0} max={perSheet - 1} defaultValue={skip} />
          </div>
          <label className="flex min-h-11 items-center gap-2 text-sm font-semibold">
            <input type="checkbox" name="price" value="1" defaultChecked={showPrice} className="h-4 w-4 accent-verdigris" />
            Print the price
          </label>
        </AutoSubmitForm>

        <p className="hint">
          In the print dialog choose US Letter paper, set scale to 100% (&ldquo;Actual size&rdquo;) and turn margins off, or the stickers will not line up.
        </p>
      </div>

      {items.length === 0 ? (
        <div className="no-print panel mt-5 px-5 py-10 text-center">
          <p className="font-semibold">Nothing to print.</p>
          <p className="mt-1 text-ink-soft">Labels are made for items that are in stock. <Link className="link" href="/inventory/new">Add an item</Link></p>
        </div>
      ) : (
        <div className="mt-5 overflow-x-auto print:mt-0 print:overflow-visible">
          <div className="sheet-wrap w-[8.5in] space-y-4 border border-line shadow-[0_1px_0_var(--color-line)] print:space-y-0">
            {sheets.map((sheet, index) => (
              <div key={index} className={`sheet sheet-${layout}`}>
                {sheet.map((item, cell) =>
                  item ? <Sticker key={item.id} item={item} large={layout === "10"} showPrice={showPrice} dealerName={dealer.name} /> : <div key={`blank-${cell}`} className="sticker" />
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {items.length > 0 && (
        <section className="no-print mt-8">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <h2 className="display text-xl">Links for NFC tags</h2>
              <p className="hint mt-1">Write an item&rsquo;s link to a blank NFC tag with any NFC writer app. Tapping the tag opens the same page as the QR code.</p>
            </div>
            <div className="flex gap-2">
              <CopyButton text={items.map((i) => i.url).join("\n")} label="Copy all links" />
              <DownloadCsvButton rows={items.map(({ goid, name, url }) => ({ goid, name, url }))} />
            </div>
          </div>
          <ul className="panel mt-4 divide-y divide-line">
            {items.map((item) => (
              <li key={item.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 px-3 py-2.5">
                <span className="goid text-sm">{item.goid}</span>
                <span className="min-w-0 flex-1 basis-40 truncate text-sm">{item.name}</span>
                <span className="break-all font-mono text-xs text-ink-soft">{item.url}</span>
                <CopyButton text={item.url} />
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}

function Sticker({ item, large, showPrice, dealerName }: { item: LabelItem; large: boolean; showPrice: boolean; dealerName: string }) {
  if (large) {
    return (
      <div className="sticker" style={{ gap: "0.18in", padding: "0.18in 0.2in" }}>
        <div className="qr" style={{ width: "1.55in", height: "1.55in" }} dangerouslySetInnerHTML={{ __html: item.qr }} />
        <div className="flex h-full min-w-0 flex-1 flex-col justify-between py-[0.02in]">
          <div>
            <p className="line-clamp-3 font-semibold" style={{ fontSize: "11.5pt", lineHeight: 1.2 }}>{item.name}</p>
            {item.condition && <p style={{ fontSize: "9pt", marginTop: "0.03in" }}>{item.condition}</p>}
          </div>
          <div>
            {showPrice && item.price != null && <p className="font-mono font-medium" style={{ fontSize: "15pt", lineHeight: 1.1 }}>{money(item.price)}</p>}
            <p className="goid" style={{ fontSize: "12pt", marginTop: "0.04in" }}>{splitGoid(item.goid)}</p>
            <p className="flex items-center gap-1" style={{ fontSize: "7.5pt", marginTop: "0.04in" }}>
              <Mark size={9} className="shrink-0" /> <span className="truncate">Scan for history. {dealerName}</span>
            </p>
          </div>
        </div>
      </div>
    );
  }
  return (
    <div className="sticker">
      <div className="qr" style={{ width: "0.8in", height: "0.8in" }} dangerouslySetInnerHTML={{ __html: item.qr }} />
      <div className="flex h-full min-w-0 flex-1 flex-col justify-between">
        <p className="line-clamp-2 font-semibold" style={{ fontSize: "7.5pt", lineHeight: 1.15 }}>{item.name}</p>
        <div>
          {showPrice && item.price != null && <p className="font-mono font-medium" style={{ fontSize: "9.5pt", lineHeight: 1.1 }}>{money(item.price)}</p>}
          <p className="goid flex items-center gap-1" style={{ fontSize: "8.5pt", marginTop: "0.02in" }}>
            <Mark size={8} className="shrink-0" /> {splitGoid(item.goid)}
          </p>
        </div>
      </div>
    </div>
  );
}
