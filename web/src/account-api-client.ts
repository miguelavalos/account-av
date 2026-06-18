import type { AccountAvAccessResponse, AccountAvAppAccess, AccountAvAppId, AccountAvUser } from "./types";

export class AccountAvApiClient {
  constructor(
    private readonly baseUrl: string,
    private readonly appId: AccountAvAppId,
    private readonly getToken: () => Promise<string | null>
  ) {}

  async getMe(): Promise<AccountAvUser> {
    return this.fetchJson<AccountAvUser>("/v1/me");
  }

  async getAccess(): Promise<AccountAvAccessResponse> {
    return this.fetchJson<AccountAvAccessResponse>("/v1/me/access");
  }

  async getAppAccess(appId: AccountAvAppId): Promise<AccountAvAppAccess | null> {
    const access = await this.getAccess();
    return access.apps.find((app) => app.appId === appId) ?? null;
  }

  private async fetchJson<T>(path: string): Promise<T> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}${path}`, {
      headers: {
        "x-appsav-app-id": this.appId,
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      }
    });

    if (!response.ok) {
      throw new Error(`Account AV request failed: ${response.status}`);
    }

    return response.json() as Promise<T>;
  }
}
