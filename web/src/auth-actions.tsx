import { SignIn, SignInButton, SignOutButton, UserButton } from "@clerk/tanstack-react-start";
import type { ReactNode } from "react";

export interface AccountSignInButtonProps {
  children: ReactNode;
  mode?: "modal" | "redirect";
}

export function AccountSignInButton({ children, mode = "modal" }: AccountSignInButtonProps) {
  return <SignInButton mode={mode}>{children}</SignInButton>;
}

export interface AccountSignInProps {
  fallbackRedirectUrl?: string;
  path: string;
  signUpUrl?: string;
}

export function AccountSignIn({ fallbackRedirectUrl = "/", path, signUpUrl }: AccountSignInProps) {
  return <SignIn fallbackRedirectUrl={fallbackRedirectUrl} path={path} routing="path" signUpUrl={signUpUrl} />;
}

export function AccountSignOutButton({ children }: { children: ReactNode }) {
  return <SignOutButton>{children}</SignOutButton>;
}

export function AccountUserButton() {
  return <UserButton />;
}
