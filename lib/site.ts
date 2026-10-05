import { headers } from "next/headers";

/**
 * The public address used inside QR codes and NFC links.
 * Set NEXT_PUBLIC_SITE_URL to pin it (for example to a custom domain).
 * On Vercel it falls back to the project's production address.
 */
export async function getSiteUrl(): Promise<string> {
  const pinned = process.env.NEXT_PUBLIC_SITE_URL;
  if (pinned) return pinned.replace(/\/+$/, "");
  const vercel = process.env.VERCEL_PROJECT_PRODUCTION_URL;
  if (vercel) return `https://${vercel}`;
  const h = await headers();
  const host = h.get("x-forwarded-host") ?? h.get("host") ?? "localhost:3000";
  const proto = h.get("x-forwarded-proto") ?? (host.startsWith("localhost") ? "http" : "https");
  return `${proto}://${host}`;
}

export function itemUrl(siteUrl: string, goid: string): string {
  return `${siteUrl}/i/${goid}`;
}
