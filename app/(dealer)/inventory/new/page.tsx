import type { Metadata } from "next";
import Link from "next/link";
import { createItem } from "@/app/actions/items";
import { ItemForm } from "@/components/ItemForm";
import { requireDealer } from "@/lib/dealer";

export const metadata: Metadata = { title: "Add item" };

export default async function NewItemPage() {
  const dealer = await requireDealer();
  return (
    <div className="mx-auto max-w-2xl">
      <p className="text-sm"><Link className="link" href="/inventory">Inventory</Link></p>
      <h1 className="display mt-2 text-3xl">Add item</h1>
      <p className="hint mt-1">Saving assigns a permanent ID and creates the public page and QR label.</p>
      <div className="panel mt-5 p-5">
        <ItemForm action={createItem} userId={dealer.id} submitLabel="Save and tag item" cancelHref="/inventory" />
      </div>
    </div>
  );
}
