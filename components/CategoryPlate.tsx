import type { Category } from "@/lib/types";

const GROUNDS = ["#1c2428", "#22332f", "#2d2a22"];

function hash(text: string): number {
  let h = 0;
  for (let i = 0; i < text.length; i++) h = (h * 31 + text.charCodeAt(i)) >>> 0;
  return h;
}

/**
 * Shown when an item has no photo yet: a line drawing of the category,
 * so the page never shows a broken or empty image.
 */
export function CategoryPlate({ category, seed, className = "" }: { category: Category; seed: string; className?: string }) {
  const ground = GROUNDS[hash(seed) % GROUNDS.length];
  const line = { fill: "none", stroke: "#e6e8e6", strokeWidth: 2, strokeLinejoin: "round" as const, strokeLinecap: "round" as const };
  const faint = { ...line, strokeOpacity: 0.45 };
  const brass = "#c2933a";

  return (
    <svg viewBox="0 0 160 160" role="img" aria-label={`No photo yet (${category})`} className={className} preserveAspectRatio="xMidYMid slice">
      <rect width="160" height="160" fill={ground} />
      {category === "coins" && (
        <>
          <circle cx="80" cy="80" r="46" {...line} />
          <circle cx="80" cy="80" r="38" {...faint} strokeDasharray="1 5" />
          <rect x="60" y="66" width="11" height="11" fill={brass} transform="rotate(-12 65 71)" />
          <rect x="88" y="86" width="8" height="8" fill={brass} transform="rotate(20 92 90)" />
          <circle cx="92" cy="62" r="4" {...faint} />
        </>
      )}
      {category === "cards" && (
        <>
          <rect x="48" y="30" width="64" height="100" rx="6" {...line} />
          <rect x="56" y="38" width="48" height="58" {...faint} />
          <path d="M56 108h34M56 118h22" {...faint} />
          <circle cx="98" cy="113" r="5" fill={brass} />
        </>
      )}
      {category === "comics" && (
        <>
          <rect x="46" y="28" width="68" height="104" {...line} />
          <path d="M46 50h68M80 50v44M46 94h68" {...faint} />
          <rect x="52" y="34" width="30" height="10" fill={brass} />
        </>
      )}
      {category === "stamps" && (
        <>
          <rect x="44" y="40" width="72" height="80" fill="none" stroke="#e6e8e6" strokeWidth="5" strokeDasharray="0.1 8" strokeLinecap="round" />
          <rect x="54" y="50" width="52" height="60" {...line} />
          <circle cx="80" cy="76" r="13" {...faint} />
          <rect x="62" y="98" width="36" height="5" fill={brass} />
        </>
      )}
      {category === "watches" && (
        <>
          <path d="M68 52V28h24v24M68 108v24h24v-24" {...faint} />
          <circle cx="80" cy="80" r="30" {...line} />
          <path d="M80 80V62M80 80l13 7" {...line} />
          <rect x="110" y="75" width="7" height="10" fill={brass} />
        </>
      )}
      {category === "art" && (
        <>
          <rect x="34" y="40" width="92" height="80" {...line} />
          <rect x="48" y="54" width="64" height="52" {...faint} />
          <path d="M48 94l20-18 16 12 14-16 14 10" {...faint} />
          <circle cx="98" cy="66" r="5" fill={brass} />
        </>
      )}
    </svg>
  );
}
