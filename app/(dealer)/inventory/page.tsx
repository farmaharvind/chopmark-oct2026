import type { Metadata } from "next";
import Link from "next/link";
import { InventoryFilters } from "@/components/InventoryFilters";
import { ItemImage } from "@/components/ItemImage";
import { StatusActions } from "@/components/StatusActions";
import { StatusBadge } from "@/components/StatusBadge";
import { requireDealer } from "@/lib/dealer";
import { CATEGORY_LABEL, money } from "@/lib/format";
import { createClient } from "@/lib/supabase/server";
import { CATEGORIES, STATUSES, type Category, type Item, type Status } from "@/lib/types";

export const metadata: Metadata = { title: "Inventory" };

const LIMIT = 500;
type Search = { q?: string; category?: string; status?: string; welcome?: string; deleted?: string };

export default async function InventoryPage({ searchParams }: { searchParams: Promise<Search> }) {
  const dealer = await requireDealer();
  const params = await searchParams;
  const q = (params.q ?? "").trim().slice(0, 80);
  const category = CATEGORIES.includes(params.category as Category) ? (params.category as Category) : "";
  const status = STATUSES.includes(params.status as Status) ? (params.status as Status) : "";

  const supabase = await createClient();
  let query = supabase
    .from("items")
    .select("id,goid,name,category,price,condition,status,photos,created_at")
    .eq("dealer_id", dealer.id)
    .order("created_at", { ascending: false })
    .limit(LIMIT);
  if (category) query = query.eq("category", category);
  if (status) query = query.eq("status", status);
  // Characters that have a special meaning in the search filter are dropped.
  const term = q.replace(/[,()"\\%*:]/g, " ").trim();
  if (term) {
    query = query.or(`name.ilike.%${term}%,goid.ilike.%${term.replace(/\s+/g, "")}%,condition.ilike.%${term}%,notes.ilike.%${term}%`);
  }
  const { data, error } = await query;
  const items = (data ?? []) as Pick<Item, "id" | "goid" | "name" | "category" | "price" | "condition" | "status" | "photos" | "created_at">[];
  const filtering = Boolean(q || category || status);

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="display text-3xl">Inventory</h1>
          <p className="hint mt-1">{dealer.name}</p>
        </div>
        <Link href="/inventory/new" className="btn btn-primary">Add item</Link>
      </div>

      {params.welcome && (
        <p role="status" className="panel border-verdigris px-4 py-3 text-sm">
          Your dealer account is ready. Add your first item to get its ID and QR label.
        </p>
      )}
      {params.deleted && (
        <p role="status" className="panel px-4 py-3 text-sm">Item deleted, along with its history.</p>
      )}

      <InventoryFilters current={{ q, category, status }} />

      {error && <p role="alert" className="panel border-alert px-4 py-3 text-sm text-alert">Inventory did not load. {error.message}</p>}

      <form id="label-form" action="/labels" method="get" className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-ink-soft">
          {items.length} {items.length === 1 ? "item" : "items"}
          {filtering ? " match" : ""}
          {items.length === LIMIT ? ` (showing the newest ${LIMIT})` : ""}
        </p>
        <div className="flex items-center gap-3">
          <span className="hint hidden sm:inline">Tick items to print only those.</span>
          <button className="btn btn-small" disabled={items.length === 0}>Print labels</button>
        </div>
      </form>

      {items.length === 0 ? (
        <div className="panel px-5 py-10 text-center">
          {filtering ? (
            <>
              <p className="font-semibold">Nothing matches those filters.</p>
              <p className="mt-1"><Link className="link" href="/inventory">Clear filters</Link></p>
            </>
          ) : (
            <>
              <p className="font-semibold">No items yet.</p>
              <p className="mt-1 text-ink-soft">Each item you add gets a permanent ID, a public page and a QR label.</p>
              <Link href="/inventory/new" className="btn btn-primary mt-4">Add your first item</Link>
            </>
          )}
        </div>
      ) : (
        <ul className="panel divide-y divide-line">
          {items.map((item) => (
            <li key={item.id} className="grid grid-cols-[auto_3.5rem_minmax(0,1fr)] items-center gap-x-3 gap-y-2.5 px-3 py-3 md:grid-cols-[auto_3.5rem_minmax(0,1fr)_6.5rem_6rem_auto]">
              <input type="checkbox" name="g" value={item.goid} form="label-form" aria-label={`Select ${item.name} for labels`} className="h-4 w-4 accent-verdigris" />
              <Link href={`/inventory/${item.goid}`} className="block h-14 w-14 overflow-hidden rounded-[3px] border border-line" tabIndex={-1} aria-hidden="true">
                <ItemImage photo={item.photos?.[0]} category={item.category} goid={item.goid} alt="" className="h-full w-full" />
              </Link>
              <div className="min-w-0">
                <Link href={`/inventory/${item.goid}`} className="block truncate font-semibold hover:underline">{item.name}</Link>
                <p className="mt-0.5 flex flex-wrap items-center gap-x-2.5 text-sm text-ink-soft">
                  <span className="goid text-[0.8125rem] text-gunmetal">{item.goid}</span>
                  <span>{CATEGORY_LABEL[item.category]}</span>
                  {item.condition && <span>{item.condition}</span>}
                </p>
                <p className="mt-1.5 flex items-center gap-2.5 md:hidden">
                  <span className="font-mono text-[0.9375rem] font-medium">{money(item.price)}</span>
                  <StatusBadge status={item.status} />
                </p>
              </div>
              <p className="hidden text-right font-mono text-[0.9375rem] font-medium md:block">{money(item.price)}</p>
              <p className="hidden md:block"><StatusBadge status={item.status} /></p>
              <div className="col-span-full flex flex-wrap gap-2 md:col-span-1 md:justify-end">
                <StatusActions id={item.id} status={item.status} />
                <Link href={`/inventory/${item.goid}`} className="btn btn-small">Edit</Link>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
