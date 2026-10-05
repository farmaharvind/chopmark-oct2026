"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const LINKS = [
  { href: "/inventory", label: "Inventory" },
  { href: "/labels", label: "Labels" },
];

export function DealerNav() {
  const pathname = usePathname();
  return (
    <nav className="flex items-center gap-1" aria-label="Dealer">
      {LINKS.map((link) => {
        const active = pathname === link.href || pathname.startsWith(link.href + "/");
        return (
          <Link
            key={link.href}
            href={link.href}
            aria-current={active ? "page" : undefined}
            className={`rounded-[3px] px-2.5 py-1.5 text-sm font-semibold ${active ? "bg-pewter text-gunmetal" : "text-pewter hover:bg-gunmetal-soft"}`}
          >
            {link.label}
          </Link>
        );
      })}
    </nav>
  );
}
