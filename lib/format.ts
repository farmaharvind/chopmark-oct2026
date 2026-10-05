import type { Category, ItemEvent, Status } from "@/lib/types";

export const CATEGORY_LABEL: Record<Category, string> = {
  coins: "Coins",
  cards: "Cards",
  comics: "Comics",
  stamps: "Stamps",
  watches: "Watches",
  art: "Art",
};

export const STATUS_LABEL: Record<Status, string> = {
  in_stock: "In stock",
  hold: "On hold",
  sold: "Sold",
};

export function money(value: number | string | null | undefined): string {
  if (value === null || value === undefined || value === "") return "Price on request";
  const n = Number(value);
  if (!Number.isFinite(n)) return "Price on request";
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: Number.isInteger(n) ? 0 : 2,
    maximumFractionDigits: 2,
  }).format(n);
}

/** GOIDs are shown in two groups of four so they are easier to read aloud. */
export function splitGoid(goid: string): string {
  return goid.length === 8 ? `${goid.slice(0, 4)} ${goid.slice(4)}` : goid;
}

export function normalizeGoid(raw: string): string {
  return decodeURIComponent(raw).toUpperCase().replace(/[^A-Z0-9]/g, "");
}

export function describeEvent(event: ItemEvent): { title: string; body?: string } {
  const d = event.detail ?? {};
  switch (event.type) {
    case "added":
      return {
        title: "Tagged and added to inventory",
        body: d.price != null ? `Listed at ${money(d.price as number)}` : undefined,
      };
    case "repriced":
      if (d.from == null) return { title: `Price set to ${money(d.to as number)}` };
      if (d.to == null) return { title: "Price removed", body: `Was ${money(d.from as number)}` };
      return { title: `Price changed to ${money(d.to as number)}`, body: `Was ${money(d.from as number)}` };
    case "sold":
      return { title: "Marked sold", body: d.price != null ? `Asking price ${money(d.price as number)}` : undefined };
    case "held":
      return { title: "Placed on hold" };
    case "restocked":
      return { title: d.from === "sold" ? "Sale reversed, back in stock" : "Hold released, back in stock" };
    case "transferred":
      return { title: "Ownership transferred" };
    case "noted":
      return { title: "Dealer note", body: event.note ?? undefined };
    default:
      return { title: event.type };
  }
}
