import { LocalDate } from "@/components/LocalDate";
import { describeEvent } from "@/lib/format";
import type { EventType, ItemEvent } from "@/lib/types";

const DOT: Record<EventType, string> = {
  added: "bg-verdigris border-verdigris",
  repriced: "bg-paper border-gunmetal",
  sold: "bg-gunmetal border-gunmetal",
  held: "bg-brass border-brass",
  restocked: "bg-paper border-verdigris",
  transferred: "bg-brass border-brass",
  noted: "bg-paper border-ink-soft",
};

/** An item's history, newest first. */
export function Timeline({ events }: { events: ItemEvent[] }) {
  if (events.length === 0) {
    return <p className="hint">No history recorded yet.</p>;
  }
  return (
    <ol className="relative">
      {events.map((event, index) => {
        const { title, body } = describeEvent(event);
        const last = index === events.length - 1;
        return (
          <li key={event.id} className="relative grid grid-cols-[1.25rem_1fr] gap-x-3 pb-5 last:pb-0">
            {!last && <span className="absolute left-[0.5625rem] top-3 bottom-0 w-px bg-line" aria-hidden="true" />}
            <span className={`relative mt-[0.4rem] h-[0.6875rem] w-[0.6875rem] justify-self-center border-[1.5px] ${DOT[event.type]} ${event.type === "noted" ? "rounded-full" : ""}`} aria-hidden="true" />
            <div>
              <p className="font-semibold leading-snug">{title}</p>
              {body && <p className="text-[0.9375rem] leading-snug text-ink-soft">{body}</p>}
              <p className="mt-0.5 font-mono text-xs text-ink-soft">
                <LocalDate iso={event.created_at} withTime />
              </p>
            </div>
          </li>
        );
      })}
    </ol>
  );
}
