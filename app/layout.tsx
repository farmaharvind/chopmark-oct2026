import type { Metadata, Viewport } from "next";
import "@fontsource-variable/archivo/wdth.css";
import "@fontsource/ibm-plex-sans/400.css";
import "@fontsource/ibm-plex-sans/500.css";
import "@fontsource/ibm-plex-sans/600.css";
import "@fontsource/ibm-plex-mono/400.css";
import "@fontsource/ibm-plex-mono/500.css";
import "./globals.css";
import { isConfigured } from "@/lib/env";
import { SetupNotice } from "@/components/SetupNotice";

export const metadata: Metadata = {
  title: { default: "Chopmark", template: "%s | Chopmark" },
  description: "Tag it. Track it. Trust it. A permanent ID and public history for every collectible.",
};

export const viewport: Viewport = {
  themeColor: "#1C2428",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{isConfigured ? children : <SetupNotice />}</body>
    </html>
  );
}
