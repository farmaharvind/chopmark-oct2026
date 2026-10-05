import type { Metadata } from "next";
import { AuthForm } from "@/components/AuthForm";
import { AuthShell } from "@/components/AuthShell";

export const metadata: Metadata = { title: "Create a dealer account" };

export default function SignupPage() {
  return (
    <AuthShell title="Create a dealer account">
      <AuthForm mode="signup" />
    </AuthShell>
  );
}
