"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { CATEGORY_LABEL, STATUS_LABEL } from "@/lib/format";
import { CATEGORIES, STATUSES } from "@/lib/types";

type Current = { q: string; category: string; status: string };

function urlFor(pathname: string, filters: Current): string {
  const params = new URLSearchParams();
  if (filters.q) params.set("q", filters.q);
  if (filters.category) params.set("category", filters.category);
  if (filters.status) params.set("status", filters.status);
  const query = params.toString();
  return query ? `${pathname}?${query}` : pathname;
}

export function InventoryFilters({ current }: { current: Current }) {
  const router = useRouter();
  const pathname = usePathname();
  const [text, setText] = useState(current.q);
  const { q, category, status } = current;

  const go = (next: Partial<Current>) => router.replace(urlFor(pathname, { q, category, status, ...next }), { scroll: false });

  // Search as the dealer types, after a short pause.
  useEffect(() => {
    const typed = text.trim();
    if (typed === q) return;
    const timer = setTimeout(() => {
      router.replace(urlFor(pathname, { q: typed, category, status }), { scroll: false });
    }, 250);
    return () => clearTimeout(timer);
  }, [text, q, category, status, pathname, router]);

  const tabs = [{ value: "", label: "All" }, ...STATUSES.map((s) => ({ value: s as string, label: STATUS_LABEL[s] }))];

  return (
    <div className="space-y-3">
      <div className="flex flex-col gap-3 sm:flex-row">
        <div className="flex-1">
          <label className="sr-only" htmlFor="inventory-search">Search inventory</label>
          <input
            id="inventory-search"
            className="field"
            type="search"
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Search by name, ID, grade or notes"
            autoComplete="off"
          />
        </div>
        <div className="sm:w-48">
          <label className="sr-only" htmlFor="inventory-category">Category</label>
          <select id="inventory-category" className="field" value={current.category} onChange={(e) => go({ category: e.target.value })}>
            <option value="">All categories</option>
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>{CATEGORY_LABEL[c]}</option>
            ))}
          </select>
        </div>
      </div>
      <div className="flex flex-wrap gap-1.5" role="group" aria-label="Filter by status">
        {tabs.map((tab) => {
          const active = current.status === tab.value;
          return (
            <button
              key={tab.value || "all"}
              type="button"
              aria-pressed={active}
              onClick={() => go({ status: tab.value })}
              className={`rounded-[3px] border px-3 py-1.5 text-sm font-semibold ${active ? "border-gunmetal bg-gunmetal text-pewter" : "border-line bg-paper hover:border-gunmetal"}`}
            >
              {tab.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
