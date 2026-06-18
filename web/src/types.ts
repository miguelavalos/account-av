export interface AccountAvUser {
  id: string;
  email?: string | null;
  displayName?: string | null;
}

export type AccountAvAppId = "tuneav" | "seriesav" | "momentsav" | "animateav" | "avapps";

export type AccountAvAccessMode = "guest" | "signedInFree" | "signedInPro";

export type AccountAvPlanTier = "free" | "pro";

export interface AccountAvAccessViewer {
  isAuthenticated: boolean;
  userId: string | null;
  identityProvider: string | null;
}

export interface AccountAvAccessCapabilities {
  isSignedIn: boolean;
  canUseBackend: boolean;
  canUsePremiumFeatures: boolean;
  canUseCloudSync: boolean;
  canManagePlan: boolean;
}

export interface AccountAvAccessLimits {
  favoriteStations: number | null;
  recentStations: number | null;
  discoveredTracks: number | null;
  savedTracks: number | null;
  aviActionsPerDay: number | null;
  lyricsSearchesPerDay: number | null;
  webSearchesPerDay: number | null;
  youtubeSearchesPerDay: number | null;
  appleMusicSearchesPerDay: number | null;
  spotifySearchesPerDay: number | null;
  discoverySharesPerDay: number | null;
}

export interface AccountAvAppAccess {
  appId: AccountAvAppId;
  accessMode: AccountAvAccessMode;
  planTier: AccountAvPlanTier;
  capabilities: AccountAvAccessCapabilities;
  limits: AccountAvAccessLimits;
}

export interface AccountAvAccessResponse {
  viewer: AccountAvAccessViewer;
  apps: AccountAvAppAccess[];
  generatedAt: string;
}

export interface AccountAvConfig {
  accountApiBaseUrl: string;
  afterSignOutUrl?: string;
  appId: AccountAvAppId;
  appDisplayName?: string;
  publishableKey: string;
  signInUrl?: string;
  signUpUrl?: string;
}
