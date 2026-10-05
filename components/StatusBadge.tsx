import { STATUS_LABEL } from "@/lib/format";
import type { Status } from "@/lib/types";

const STYLE: Record<Status, string> = {
  in_stock: "border-verdigris text-verdigris-deep",
  hold: "border-brass text-brass-deep",
  sold: "border-gunmetal bg-gunmetal text-pewter",
};
const DOT: Record<Status, string> = {
  in_stock: "bg-verdigris",
  hold: "bg-brass",
  sold: "bg-pewter",
};

export function StatusBadge({ status, large = false }: { status: Status; large?: boolean }) {
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-[3px] border font-semibold whitespace-nowrap ${STYLE[status]} ${
        large ? "px-2.5 py-1 text-sm" : "px-2 py-0.5 text-xs"
      }`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${DOT[status]}`} aria-hidden="true" />
      {STATUS_LABEL[status]}
    </span>
  );
}
