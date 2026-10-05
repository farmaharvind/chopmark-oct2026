export const CATEGORIES = ["coins", "cards", "comics", "stamps", "watches", "art"] as const;
export type Category = (typeof CATEGORIES)[number];

export const STATUSES = ["in_stock", "hold", "sold"] as const;
export type Status = (typeof STATUSES)[number];

export type Dealer = {
  id: string;
  name: string;
  slug: string;
  created_at: string;
};

export type Item = {
  id: string;
  goid: string;
  dealer_id: string;
  name: string;
  category: Category;
  price: number | null;
  condition: string | null;
  notes: string | null;
  status: Status;
  photos: string[];
  created_at: string;
  updated_at: string;
  sold_at: string | null;
};

export type EventType = "added" | "repriced" | "sold" | "held" | "restocked" | "transferred" | "noted";

export type ItemEvent = {
  id: number;
  item_id: string;
  type: EventType;
  detail: Record<string, unknown>;
  note: string | null;
  created_at: string;
};
