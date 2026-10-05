import { setStatus } from "@/app/actions/items";
import type { Status } from "@/lib/types";

const NEXT: Record<Status, { status: Status; label: string; primary?: boolean }[]> = {
  in_stock: [
    { status: "sold", label: "Mark sold", primary: true },
    { status: "hold", label: "Hold" },
  ],
  hold: [
    { status: "sold", label: "Mark sold", primary: true },
    { status: "in_stock", label: "Release hold" },
  ],
  sold: [{ status: "in_stock", label: "Back in stock" }],
};

/** One-tap buttons for the status changes that make sense from the current status. */
export function StatusActions({ id, status }: { id: string; status: Status }) {
  return (
    <>
      {NEXT[status].map((option) => (
        <form key={option.status} action={setStatus}>
          <input type="hidden" name="id" value={id} />
          <input type="hidden" name="status" value={option.status} />
          <button className={`btn btn-small ${option.primary ? "!border-verdigris !text-verdigris-deep hover:!bg-verdigris hover:!text-white" : ""}`}>
            {option.label}
          </button>
        </form>
      ))}
    </>
  );
}
