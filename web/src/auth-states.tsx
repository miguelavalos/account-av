import type { ReactNode } from "react";
import { useAccountSession } from "./account-av-provider";

export function AuthLoading({ children }: { children: ReactNode }) {
  const session = useAccountSession();
  return !session.isLoaded ? <>{children}</> : null;
}

export function SignedIn({ children }: { children: ReactNode }) {
  const session = useAccountSession();
  return session.isLoaded && session.isSignedIn ? <>{children}</> : null;
}

export function SignedOut({ children }: { children: ReactNode }) {
  const session = useAccountSession();
  return session.isLoaded && !session.isSignedIn ? <>{children}</> : null;
}
