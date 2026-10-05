"use client";

import { useEffect, useState } from "react";

const DATE: Intl.DateTimeFormatOptions = { month: "short", day: "numeric", year: "numeric" };
const TIME: Intl.DateTimeFormatOptions = { hour: "numeric", minute: "2-digit" };

/** Shows a timestamp in the viewer's own time zone. */
export function LocalDate({ iso, withTime = false }: { iso: string; withTime?: boolean }) {
  const [text, setText] = useState(() =>
    new Date(iso).toLocaleDateString("en-US", { ...DATE, timeZone: "UTC" })
  );
  useEffect(() => {
    const d = new Date(iso);
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setText(withTime ? d.toLocaleString("en-US", { ...DATE, ...TIME }) : d.toLocaleDateString("en-US", DATE));
  }, [iso, withTime]);
  return (
    <time dateTime={iso} suppressHydrationWarning>
      {text}
    </time>
  );
}
