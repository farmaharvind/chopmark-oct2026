import Link from "next/link";
import { Wordmark } from "@/components/Mark";

export default function NotFound() {
  return (
    <main className="mx-auto w-full max-w-md px-5 py-16">
      <Link href="/" aria-label="Chopmark home"><Wordmark /></Link>
      <h1 className="display mt-8 text-3xl">Nothing is recorded at this address</h1>
      <p className="mt-4">
        If you scanned a tag, the ID on it may have been mistyped or the item was removed by its dealer. Chopmark IDs are 8 letters and numbers.
      </p>
      <p className="mt-6"><Link className="btn" href="/">Go to Chopmark</Link></p>
    </main>
  );
}
