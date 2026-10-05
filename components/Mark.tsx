/** The Chopmark mark: a small plate with a hexagon punched through it. */
export function Mark({ size = 22, className }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" aria-hidden="true" className={className}>
      <path
        fill="currentColor"
        fillRule="evenodd"
        d="M3 1h18a2 2 0 0 1 2 2v18a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2Zm9 5.2 5 2.9v5.8l-5 2.9-5-2.9V9.1l5-2.9Z"
      />
    </svg>
  );
}

export function Wordmark({ className = "" }: { className?: string }) {
  return (
    <span className={`inline-flex items-center gap-2 ${className}`}>
      <Mark size={20} />
      <span className="display text-[1.05rem] tracking-normal">Chopmark</span>
    </span>
  );
}
