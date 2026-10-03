/**
 * Server-side client for the private api service.
 *
 * The browser never calls the api. This module runs on the web server, mints a
 * Google identity token for the web service account and sends it as a Bearer
 * token; Cloud Run accepts it because run-web has roles/run.invoker on api.
 * Locally there is no metadata server, so the call goes without a token and
 * API_URL points to a local uvicorn.
 */
import { GoogleAuth } from "google-auth-library";

export type Health = { ok: boolean; version: string; commit: string };

const apiUrl = process.env.API_URL ?? "http://localhost:8080";

async function authHeaders(): Promise<HeadersInit> {
  if (!apiUrl.startsWith("https://")) return {};
  const auth = new GoogleAuth();
  const client = await auth.getIdTokenClient(apiUrl);
  return client.getRequestHeaders(apiUrl);
}

export async function getApiHealth(): Promise<Health | null> {
  try {
    const response = await fetch(`${apiUrl}/health`, {
      headers: await authHeaders(),
      cache: "no-store",
    });
    if (!response.ok) return null;
    return (await response.json()) as Health;
  } catch {
    return null;
  }
}

/** Pure helper so the page copy is testable without a network. */
export function describeHealth(health: Health | null): string {
  if (!health || !health.ok) return "La API no responde.";
  return `API en línea, versión ${health.version} (${health.commit.slice(0, 7)}).`;
}
