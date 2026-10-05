"use client";

import Link from "next/link";
import { useActionState, useRef, useState } from "react";
import type { ItemFormState } from "@/app/actions/items";
import { PHOTO_BUCKET } from "@/lib/env";
import { CATEGORY_LABEL, STATUS_LABEL } from "@/lib/format";
import { createClient } from "@/lib/supabase/client";
import { CATEGORIES, STATUSES, type Item } from "@/lib/types";

const MAX_PHOTOS = 8;
const MAX_EDGE = 1600;

/** Phone photos are large. Shrink them in the browser before uploading. */
async function shrink(file: File): Promise<Blob> {
  try {
    const bitmap = await createImageBitmap(file);
    const scale = Math.min(1, MAX_EDGE / Math.max(bitmap.width, bitmap.height));
    const canvas = document.createElement("canvas");
    canvas.width = Math.round(bitmap.width * scale);
    canvas.height = Math.round(bitmap.height * scale);
    canvas.getContext("2d")?.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
    bitmap.close();
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, "image/jpeg", 0.85));
    return blob ?? file;
  } catch {
    return file;
  }
}

type Props = {
  action: (state: ItemFormState, formData: FormData) => Promise<ItemFormState>;
  userId: string;
  item?: Item;
  submitLabel: string;
  cancelHref: string;
};

export function ItemForm({ action, userId, item, submitLabel, cancelHref }: Props) {
  const [state, formAction, pending] = useActionState<ItemFormState, FormData>(action, {});
  const [photos, setPhotos] = useState<string[]>(item?.photos ?? []);
  const [uploading, setUploading] = useState(0);
  const [uploadError, setUploadError] = useState<string | null>(null);
  const fileInput = useRef<HTMLInputElement>(null);
  // The two dropdowns are held in state so they keep their value when the
  // form comes back with an error.
  const [category, setCategory] = useState<string>(item?.category ?? "");
  const [status, setStatus] = useState<string>(item?.status ?? "in_stock");

  const v = state.values;
  const initial = {
    name: v?.name ?? item?.name ?? "",
    price: v?.price ?? (item?.price != null ? String(item.price) : ""),
    condition: v?.condition ?? item?.condition ?? "",
    notes: v?.notes ?? item?.notes ?? "",
  };

  async function onFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    setUploadError(null);
    const room = MAX_PHOTOS - photos.length;
    const chosen = Array.from(files).slice(0, room);
    if (files.length > room) setUploadError(`An item can have up to ${MAX_PHOTOS} photos. The extra ones were skipped.`);

    const supabase = createClient();
    setUploading(chosen.length);
    for (const file of chosen) {
      const blob = await shrink(file);
      const ext = blob.type === "image/jpeg" ? "jpg" : (file.name.split(".").pop() || "jpg").toLowerCase();
      const path = `${userId}/${crypto.randomUUID()}.${ext}`;
      const { error } = await supabase.storage
        .from(PHOTO_BUCKET)
        .upload(path, blob, { contentType: blob.type || file.type, cacheControl: "31536000" });
      if (error) {
        setUploadError(`A photo did not upload (${error.message}). Try again.`);
      } else {
        const url = supabase.storage.from(PHOTO_BUCKET).getPublicUrl(path).data.publicUrl;
        setPhotos((current) => [...current, url]);
      }
      setUploading((n) => n - 1);
    }
    if (fileInput.current) fileInput.current.value = "";
  }

  return (
    <form action={formAction} className="space-y-5">
      {item && <input type="hidden" name="id" value={item.id} />}
      <input type="hidden" name="photos" value={JSON.stringify(photos)} />

      <div>
        <label className="label" htmlFor="name">Item name</label>
        <input className="field" id="name" name="name" required maxLength={200} defaultValue={initial.name} placeholder="1881-S Morgan Silver Dollar" />
      </div>

      <div className="grid gap-5 sm:grid-cols-2">
        <div>
          <label className="label" htmlFor="category">Category</label>
          <select className="field" id="category" name="category" required value={category} onChange={(e) => setCategory(e.target.value)}>
            <option value="" disabled>Choose one</option>
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>{CATEGORY_LABEL[c]}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="label" htmlFor="condition">Condition or grade</label>
          <input className="field" id="condition" name="condition" maxLength={80} defaultValue={initial.condition} placeholder="MS-65, PSA 8, CGC 9.2, Very good" />
        </div>
        <div>
          <label className="label" htmlFor="price">Price (USD)</label>
          <input className="field font-mono" id="price" name="price" inputMode="decimal" defaultValue={initial.price} placeholder="285" />
          <p className="hint mt-1">Leave empty to show &ldquo;Price on request&rdquo;.</p>
        </div>
        <div>
          <label className="label" htmlFor="status">Status</label>
          <select className="field" id="status" name="status" value={status} onChange={(e) => setStatus(e.target.value)}>
            {STATUSES.map((s) => (
              <option key={s} value={s}>{STATUS_LABEL[s]}</option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="label" htmlFor="notes">Notes</label>
        <textarea className="field" id="notes" name="notes" rows={4} maxLength={4000} defaultValue={initial.notes} placeholder="Strike, toning, flaws, what comes with it." />
        <p className="hint mt-1">Buyers see these notes on the item&rsquo;s public page.</p>
      </div>

      <div>
        <span className="label">Photos</span>
        <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
          {photos.map((url, index) => (
            <div key={url} className="relative aspect-square overflow-hidden rounded-[3px] border border-line bg-white">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={url} alt={`Photo ${index + 1}`} className="h-full w-full object-cover" />
              {index === 0 ? (
                <span className="absolute left-1 top-1 rounded-[2px] bg-gunmetal px-1.5 py-0.5 text-[0.6875rem] font-semibold text-pewter">Cover</span>
              ) : (
                <button type="button" onClick={() => setPhotos((p) => [url, ...p.filter((x) => x !== url)])} className="absolute left-1 top-1 rounded-[2px] bg-paper/95 px-1.5 py-0.5 text-[0.6875rem] font-semibold">
                  Make cover
                </button>
              )}
              <button type="button" onClick={() => setPhotos((p) => p.filter((x) => x !== url))} aria-label={`Remove photo ${index + 1}`} className="absolute right-1 top-1 grid h-6 w-6 place-items-center rounded-[2px] bg-paper/95 text-sm font-bold leading-none">
                &times;
              </button>
            </div>
          ))}
          {photos.length < MAX_PHOTOS && (
            <label className="grid aspect-square cursor-pointer place-items-center rounded-[3px] border border-dashed border-gunmetal bg-white p-2 text-center text-sm font-semibold hover:bg-pewter focus-within:outline-2 focus-within:outline-verdigris">
              <input ref={fileInput} type="file" accept="image/*" multiple className="sr-only" onChange={(e) => onFiles(e.target.files)} />
              {uploading > 0 ? `Uploading ${uploading}` : photos.length ? "Add another" : "Add photos"}
            </label>
          )}
        </div>
        {uploadError && <p role="alert" className="mt-2 text-sm font-medium text-alert">{uploadError}</p>}
        <p className="hint mt-2">Up to {MAX_PHOTOS}. The first photo is the cover. Items without a photo show a category drawing.</p>
      </div>

      {state.error && <p role="alert" className="rounded-[3px] border border-alert bg-white px-3 py-2 text-sm font-medium text-alert">{state.error}</p>}

      <div className="flex flex-wrap gap-3">
        <button className="btn btn-primary" disabled={pending || uploading > 0}>
          {pending ? "Saving" : uploading > 0 ? "Waiting for photos" : submitLabel}
        </button>
        <Link className="btn" href={cancelHref}>Cancel</Link>
      </div>
    </form>
  );
}
