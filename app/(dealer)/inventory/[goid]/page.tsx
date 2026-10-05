import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { addNote, deleteItem, updateItem } from "@/app/actions/items";
import { ConfirmButton } from "@/components/ConfirmButton";
import { CopyButton } from "@/components/CopyButton";
import { GoidPlate } from "@/components/GoidPlate";
import { ItemForm } from "@/components/ItemForm";
import { StatusActions } from "@/components/StatusActions";
import { StatusBadge } from "@/components/StatusBadge";
import { Timeline } from "@/components/Timeline";
import { requireDealer } from "@/lib/dealer";
import { normalizeGoid } from "@/lib/format";
import { qrSvg } from "@/lib/qr";
import { getSiteUrl, itemUrl } from "@/lib/site";
import { createClient } from "@/lib/supabase/server";
import type { Item, ItemEvent } from "@/lib/types";

export const metadata: Metadata = { title: "Edit item" };

type Props = { params: Promise<{ goid: string }>; searchParams: Promise<{ added?: string; saved?: string }> };

export default async function EditItemPage({ params, searchParams }: Props) {
  const dealer = await requireDealer();
  const goid = normalizeGoid((await params).goid);
  const flags = await searchParams;

  const supabase = await createClient();
  const { data } = await supabase.from("items").select("*").eq("goid", goid).eq("dealer_id", dealer.id).maybeSingle();
  const item = data as Item | null;
  if (!item) notFound();

  const { data: eventRows } = await supabase
    .from("events")
    .select("id,item_id,type,detail,note,created_at")
    .eq("item_id", item.id)
    .order("created_at", { ascending: false })
    .order("id", { ascending: false });
  const events = (eventRows ?? []) as ItemEvent[];

  const url = itemUrl(await getSiteUrl(), item.goid);
  const qr = await qrSvg(url, "#1c2428");

  return (
    <div>
      <p className="text-sm"><Link className="link" href="/inventory">Inventory</Link></p>
      <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-2">
        <h1 className="display min-w-0 text-2xl sm:text-3xl">{item.name}</h1>
        <StatusBadge status={item.status} large />
      </div>

      {flags.added && (
        <p role="status" className="panel mt-4 border-verdigris px-4 py-3 text-sm">
          <strong>Tagged.</strong> This item now has a permanent ID and a public page. Print its label or write the link to an NFC tag.
        </p>
      )}
      {flags.saved && (
        <p role="status" className="panel mt-4 border-verdigris px-4 py-3 text-sm"><strong>Saved.</strong> Price and status changes are in the history.</p>
      )}

      <div className="mt-5 grid gap-6 lg:grid-cols-[minmax(0,1fr)_22rem]">
        <section className="panel p-5" aria-label="Item details">
          <ItemForm key={item.updated_at} action={updateItem} userId={dealer.id} item={item} submitLabel="Save changes" cancelHref="/inventory" />
        </section>

        <aside className="space-y-5">
          <section className="panel p-5" aria-label="Tag">
            <div className="flex items-start gap-4">
              <div className="h-24 w-24 shrink-0 rounded-[3px] border border-line bg-white p-1.5" dangerouslySetInnerHTML={{ __html: qr }} />
              <div className="min-w-0 space-y-2">
                <GoidPlate goid={item.goid} />
                <p className="break-all font-mono text-xs text-ink-soft">{url}</p>
              </div>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              <Link className="btn btn-small" href={`/i/${item.goid}`} target="_blank">View public page</Link>
              <Link className="btn btn-small" href={`/labels?g=${item.goid}`}>Print label</Link>
              <CopyButton text={url} label="Copy link for NFC" />
            </div>
          </section>

          <section className="panel p-5" aria-label="Status">
            <h2 className="font-semibold">Change status</h2>
            <div className="mt-3 flex flex-wrap gap-2">
              <StatusActions id={item.id} status={item.status} />
            </div>
          </section>

          <section className="panel p-5">
            <h2 className="font-semibold">History</h2>
            <p className="hint mt-0.5">Recorded automatically and shown to buyers. It cannot be edited.</p>
            <form action={addNote} className="mt-4 flex gap-2">
              <input type="hidden" name="id" value={item.id} />
              <label className="sr-only" htmlFor="note">Add a note to the history</label>
              <input className="field" id="note" name="note" required maxLength={1000} placeholder="Add a note to the history" />
              <button className="btn shrink-0">Add</button>
            </form>
            <div className="mt-5">
              <Timeline events={events} />
            </div>
          </section>

          <form action={deleteItem} className="text-right">
            <input type="hidden" name="id" value={item.id} />
            <ConfirmButton className="btn btn-small btn-danger" message={`Delete "${item.name}" and its whole history? The ID ${item.goid} will stop working. This cannot be undone.`}>
              Delete item
            </ConfirmButton>
          </form>
        </aside>
      </div>
    </div>
  );
}
