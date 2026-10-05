"use client";

export function AutoSubmitForm({ action, className, children }: { action: string; className?: string; children: React.ReactNode }) {
  return (
    <form action={action} method="get" className={className} onChange={(event) => event.currentTarget.requestSubmit()}>
      {children}
    </form>
  );
}

export function PrintButton({ disabled = false }: { disabled?: boolean }) {
  return (
    <button type="button" className="btn btn-primary" disabled={disabled} onClick={() => window.print()}>
      Print labels
    </button>
  );
}

export function DownloadCsvButton({ rows }: { rows: { goid: string; name: string; url: string }[] }) {
  return (
    <button
      type="button"
      className="btn btn-small"
      onClick={() => {
        const cell = (value: string) => `"${value.replace(/"/g, '""')}"`;
        const csv = ["goid,name,url", ...rows.map((r) => [r.goid, r.name, r.url].map(cell).join(","))].join("\r\n");
        const link = document.createElement("a");
        link.href = URL.createObjectURL(new Blob([csv], { type: "text/csv" }));
        link.download = "chopmark-nfc-links.csv";
        link.click();
        URL.revokeObjectURL(link.href);
      }}
    >
      Download as CSV
    </button>
  );
}
