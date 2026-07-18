import { SignIn, SignInButton, SignOutButton } from "@clerk/react";
import type { ComponentProps } from "react";
import type { ReactNode } from "react";

export interface AccountSignInButtonProps {
  children: ReactNode;
  mode?: "modal" | "redirect";
}

export function AccountSignInButton({ children, mode = "modal" }: AccountSignInButtonProps) {
  return <SignInButton mode={mode}>{children}</SignInButton>;
}

export interface AccountSignInProps {
  appearance?: ComponentProps<typeof SignIn>["appearance"];
  fallbackRedirectUrl?: string;
  path: string;
  signUpUrl?: string;
}

export function AccountSignIn({ appearance, fallbackRedirectUrl = "/", path, signUpUrl }: AccountSignInProps) {
  return <SignIn appearance={appearance} fallbackRedirectUrl={fallbackRedirectUrl} path={path} routing="path" signUpUrl={signUpUrl} />;
}

export function AccountSignOutButton({ children }: { children: ReactNode }) {
  return <SignOutButton>{children}</SignOutButton>;
}

export interface AccountUserButtonProps {
  href?: string;
  label?: string;
}

export function AccountUserButton({ href = "/account", label = "Account" }: AccountUserButtonProps) {
  return (
    <a
      aria-label={label}
      className="inline-flex h-9 items-center rounded-full border border-border bg-background px-3 text-sm font-semibold text-foreground transition hover:bg-muted"
      href={href}
    >
      {label}
    </a>
  );
}
