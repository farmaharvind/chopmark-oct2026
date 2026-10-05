import { splitGoid } from "@/lib/format";

/**
 * The item's ID, drawn as a stamped metal tag with a punched hole.
 * This is the one piece of the interface that is meant to be recognisable.
 */
export function GoidPlate({ goid, size = "md" }: { goid: string; size?: "sm" | "md" | "lg" }) {
  const text = size === "lg" ? "text-2xl sm:text-3xl" : size === "md" ? "text-xl" : "text-sm";
  const pad = size === "sm" ? "pl-2 pr-2.5 py-1 gap-2" : "pl-3 pr-4 py-2 gap-3";
  const hole = size === "sm" ? "h-2.5 w-2.5" : "h-4 w-4";
  return (
    <span
      className={`inline-flex items-center ${pad} rounded-[3px] border-[1.5px] border-brass bg-gunmetal text-pewter`}
      title="Chopmark ID (GOID)"
    >
      <span className={`${hole} shrink-0 rounded-full bg-pewter shadow-[inset_0_1px_2px_rgba(28,36,40,0.55)]`} aria-hidden="true" />
      <span className="flex flex-col leading-none">
        {size !== "sm" && <span className="mb-1 text-[0.6875rem] font-medium text-brass">Chopmark ID</span>}
        <span className={`goid ${text}`} aria-label={`Chopmark ID ${goid.split("").join(" ")}`}>
          {splitGoid(goid)}
        </span>
      </span>
    </span>
  );
}
