"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { PHOTO_BUCKET, SUPABASE_URL } from "@/lib/env";
import { requireDealer } from "@/lib/dealer";
import { createClient } from "@/lib/supabase/server";
import { CATEGORIES, STATUSES, type Category, type Status } from "@/lib/types";

export type ItemValues = {
  name: string;
  category: string;
  price: string;
  condition: string;
  notes: string;
  status: string;
};
export type ItemFormState = { error?: string; values?: ItemValues };

const MAX_PHOTOS = 8;

function readForm(formData: FormData) {
  const values: ItemValues = {
    name: String(formData.get("name") ?? "").trim(),
    category: String(formData.get("category") ?? ""),
    price: String(formData.get("price") ?? "").trim(),
    condition: String(formData.get("condition") ?? "").trim(),
    notes: String(formData.get("notes") ?? "").trim(),
    status: String(formData.get("status") ?? "in_stock"),
  };

  if (!values.name) return { values, error: "Give the item a name." };
  if (!CATEGORIES.includes(values.category as Category)) return { values, error: "Choose a category." };
  if (!STATUSES.includes(values.status as Status)) return { values, error: "Choose a status." };

  let price: number | null = null;
  if (values.price) {
    const n = Number(values.price.replace(/[$,\s]/g, ""));
    if (!Number.isFinite(n) || n < 0) return { values, error: "Enter the price as a number, like 450 or 1,250.50." };
    if (n > 9_999_999_999) return { values, error: "That price is too large." };
    price = Math.round(n * 100) / 100;
  }

  let photos: string[] = [];
  try {
    const parsed = JSON.parse(String(formData.get("photos") ?? "[]"));
    const prefix = `${SUPABASE_URL}/storage/v1/object/public/${PHOTO_BUCKET}/`;
    if (Array.isArray(parsed)) {
      photos = parsed.filter((p): p is string => typeof p === "string" && p.startsWith(prefix)).slice(0, MAX_PHOTOS);
    }
  } catch {
    photos = [];
  }

  return {
    values,
    row: {
      name: values.name,
      category: values.category as Category,
      price,
      condition: values.condition || null,
      notes: values.notes || null,
      status: values.status as Status,
      photos,
    },
  };
}

export async function createItem(_prev: ItemFormState, formData: FormData): Promise<ItemFormState> {
  const dealer = await requireDealer();
  const { values, row, error } = readForm(formData);
  if (error || !row) return { error, values };

  const supabase = await createClient();
  const { data, error: dbError } = await supabase
    .from("items")
    .insert({ ...row, dealer_id: dealer.id })
    .select("goid")
    .single();
  if (dbError || !data) return { error: `The item was not saved. ${dbError?.message ?? ""}`.trim(), values };

  revalidatePath("/inventory");
  redirect(`/inventory/${data.goid}?added=1`);
}

export async function updateItem(_prev: ItemFormState, formData: FormData): Promise<ItemFormState> {
  await requireDealer();
  const id = String(formData.get("id") ?? "");
  const { values, row, error } = readForm(formData);
  if (error || !row) return { error, values };

  const supabase = await createClient();
  const { data, error: dbError } = await supabase.from("items").update(row).eq("id", id).select("goid");
  if (dbError) return { error: `Your changes were not saved. ${dbError.message}`, values };
  if (!data || data.length === 0) return { error: "Your changes were not saved. This item belongs to another dealer.", values };

  revalidatePath("/inventory");
  redirect(`/inventory/${data[0].goid}?saved=1`);
}

/** One-tap status change from the inventory list or the item page. */
export async function setStatus(formData: FormData) {
  await requireDealer();
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  if (!STATUSES.includes(status as Status)) return;

  const supabase = await createClient();
  await supabase.from("items").update({ status }).eq("id", id);
  revalidatePath("/inventory", "layout");
}

export async function addNote(formData: FormData) {
  await requireDealer();
  const itemId = String(formData.get("id") ?? "");
  const note = String(formData.get("note") ?? "").trim().slice(0, 1000);
  if (!note) return;

  const supabase = await createClient();
  await supabase.from("events").insert({ item_id: itemId, type: "noted", note });
  revalidatePath("/inventory", "layout");
}

export async function deleteItem(formData: FormData) {
  await requireDealer();
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("items").delete().eq("id", id);
  revalidatePath("/inventory");
  redirect("/inventory?deleted=1");
}
