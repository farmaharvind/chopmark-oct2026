import { CategoryPlate } from "@/components/CategoryPlate";
import type { Category } from "@/lib/types";

/** The item's first photo, or the category drawing when there is none. */
export function ItemImage({
  photo,
  category,
  goid,
  alt,
  className = "",
}: {
  photo?: string | null;
  category: Category;
  goid: string;
  alt: string;
  className?: string;
}) {
  if (photo) {
    // eslint-disable-next-line @next/next/no-img-element
    return <img src={photo} alt={alt} loading="lazy" className={`object-cover ${className}`} />;
  }
  return <CategoryPlate category={category} seed={goid} className={className} />;
}
