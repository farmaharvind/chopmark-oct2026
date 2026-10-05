"use client";

import Link from "next/link";
import { useActionState } from "react";
import { login, signup, type AuthState } from "@/app/actions/auth";

export function AuthForm({ mode, next = "" }: { mode: "login" | "signup"; next?: string }) {
  const [state, action, pending] = useActionState<AuthState, FormData>(mode === "login" ? login : signup, {});
  const isSignup = mode === "signup";

  return (
    <form action={action} className="space-y-4">
      <input type="hidden" name="next" value={next} />
      {isSignup && (
        <div>
          <label className="label" htmlFor="dealer_name">Business or dealer name</label>
          <input className="field" id="dealer_name" name="dealer_name" required autoComplete="organization" defaultValue={state.dealerName ?? ""} />
          <p className="hint mt-1">Shown to buyers on every item you tag.</p>
        </div>
      )}
      <div>
        <label className="label" htmlFor="email">Email</label>
        <input className="field" id="email" name="email" type="email" required autoComplete="email" defaultValue={state.email ?? ""} />
      </div>
      <div>
        <label className="label" htmlFor="password">Password</label>
        <input className="field" id="password" name="password" type="password" required minLength={isSignup ? 8 : undefined} autoComplete={isSignup ? "new-password" : "current-password"} />
        {isSignup && <p className="hint mt-1">At least 8 characters.</p>}
      </div>

      {state.error && <p role="alert" className="rounded-[3px] border border-alert bg-white px-3 py-2 text-sm font-medium text-alert">{state.error}</p>}
      {state.notice && <p role="status" className="rounded-[3px] border border-verdigris bg-white px-3 py-2 text-sm font-medium text-verdigris-deep">{state.notice}</p>}

      <button className="btn btn-primary w-full" disabled={pending}>
        {pending ? "One moment" : isSignup ? "Create dealer account" : "Log in"}
      </button>

      <p className="text-sm">
        {isSignup ? (
          <>Already tagging with Chopmark? <Link className="link" href="/login">Log in</Link></>
        ) : (
          <>New dealer? <Link className="link" href="/signup">Create an account</Link></>
        )}
      </p>
    </form>
  );
}
