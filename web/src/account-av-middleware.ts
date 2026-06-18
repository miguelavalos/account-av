import { clerkMiddleware } from "@clerk/tanstack-react-start/server";

declare const process: {
  env?: Record<string, string | undefined>;
};

export function accountAvMiddleware() {
  return clerkMiddleware({
    publishableKey:
      process.env?.CLERK_PUBLISHABLE_KEY ??
      import.meta.env.VITE_ACCOUNTAV_PUBLISHABLE_KEY,
    secretKey: process.env?.CLERK_SECRET_KEY
  });
}
