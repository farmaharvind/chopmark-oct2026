import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { SUPABASE_KEY, SUPABASE_URL, isConfigured } from "@/lib/env";

const DEALER_ONLY = ["/inventory", "/labels"];

// Runs before every page: keeps the login session fresh and keeps
// signed-out visitors away from the dealer screens.
export async function proxy(request: NextRequest) {
  let response = NextResponse.next({ request });
  if (!isConfigured) return response;

  const supabase = createServerClient(SUPABASE_URL, SUPABASE_KEY, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet, headers) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
        Object.entries(headers ?? {}).forEach(([key, value]) => response.headers.set(key, value));
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const path = request.nextUrl.pathname;
  const redirectTo = (pathname: string, next?: string) => {
    const url = request.nextUrl.clone();
    url.pathname = pathname;
    url.search = next ? `?next=${encodeURIComponent(next)}` : "";
    const redirect = NextResponse.redirect(url);
    response.cookies.getAll().forEach((cookie) => redirect.cookies.set(cookie));
    return redirect;
  };

  if (!user && DEALER_ONLY.some((prefix) => path === prefix || path.startsWith(prefix + "/"))) {
    return redirectTo("/login", path + request.nextUrl.search);
  }
  if (user && (path === "/login" || path === "/signup") && !request.nextUrl.searchParams.has("missing")) {
    return redirectTo("/inventory");
  }
  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|icon.svg|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico|woff2?)$).*)"],
};
