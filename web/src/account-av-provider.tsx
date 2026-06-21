import { ClerkProvider, useAuth, useUser } from "@clerk/tanstack-react-start";
import { useQuery } from "@tanstack/react-query";
import type { ComponentProps } from "react";
import type { ReactNode } from "react";
import { createContext, useContext, useMemo } from "react";
import { AccountAvApiClient } from "./account-api-client";
import type { AccountAvAccessResponse, AccountAvAppAccess, AccountAvAppId, AccountAvConfig, AccountAvUser } from "./types";

interface AccountAvContextValue {
  client: AccountAvApiClient;
  getToken: () => Promise<string | null>;
}

const AccountAvContext = createContext<AccountAvContextValue | null>(null);

export interface AccountAvProviderProps extends AccountAvConfig {
  children: ReactNode;
  localization?: ComponentProps<typeof ClerkProvider>["localization"];
}

export function AccountAvProvider({ accountApiBaseUrl, afterSignOutUrl, appDisplayName, appId, children, localization, publishableKey, signInUrl, signUpUrl }: AccountAvProviderProps) {
  const defaultLocalization =
    appDisplayName
      ? {
          signIn: {
            start: {
              title: `Sign in to ${appDisplayName}`,
              subtitle: "Welcome back. Please sign in to continue."
            }
          }
        }
      : undefined;

  return (
    <ClerkProvider
      afterSignOutUrl={afterSignOutUrl}
      localization={localization ?? defaultLocalization}
      publishableKey={publishableKey}
      signInUrl={signInUrl}
      signUpUrl={signUpUrl}
    >
      <AccountAvRuntimeProvider accountApiBaseUrl={accountApiBaseUrl} appId={appId}>
        {children}
      </AccountAvRuntimeProvider>
    </ClerkProvider>
  );
}

function AccountAvRuntimeProvider({ accountApiBaseUrl, appId, children }: { accountApiBaseUrl: string; appId: AccountAvAppId; children: ReactNode }) {
  const { getToken } = useAuth();
  const value = useMemo(() => {
    const tokenProvider = () => getToken();
    return {
      client: new AccountAvApiClient(accountApiBaseUrl, appId, tokenProvider),
      getToken: tokenProvider
    };
  }, [accountApiBaseUrl, appId, getToken]);

  return <AccountAvContext.Provider value={value}>{children}</AccountAvContext.Provider>;
}

export function useAccountAvClient() {
  const context = useContext(AccountAvContext);
  if (!context) {
    throw new Error("useAccountAvClient must be used inside AccountAvProvider.");
  }
  return context;
}

export function useAccountSession() {
  const auth = useAuth();
  return {
    isLoaded: auth.isLoaded,
    isSignedIn: auth.isSignedIn,
    sessionId: auth.sessionId,
    userId: auth.userId
  };
}

export function useAccountToken() {
  return useAccountAvClient().getToken;
}

export function useAccountUser() {
  const session = useAccountSession();
  const user = useUser();
  const { client } = useAccountAvClient();

  return useQuery<AccountAvUser>({
    enabled: Boolean(session.isLoaded && session.isSignedIn),
    queryFn: () => client.getMe(),
    queryKey: ["account-av", "me", session.userId, session.sessionId, user.user?.id]
  });
}

export function useAccountAccess() {
  const session = useAccountSession();
  const { client } = useAccountAvClient();

  return useQuery<AccountAvAccessResponse>({
    enabled: Boolean(session.isLoaded && session.isSignedIn),
    queryFn: () => client.getAccess(),
    queryKey: ["account-av", "access", session.userId, session.sessionId]
  });
}

export function useAccountAppAccess(appId: AccountAvAppId) {
  const session = useAccountSession();
  const { client } = useAccountAvClient();

  return useQuery<AccountAvAppAccess | null>({
    enabled: Boolean(session.isLoaded && session.isSignedIn),
    queryFn: () => client.getAppAccess(appId),
    queryKey: ["account-av", "access", appId, session.userId, session.sessionId]
  });
}
