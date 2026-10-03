import { describe, expect, it } from "vitest";
import { describeHealth } from "./api";

describe("describeHealth", () => {
  it("reports an offline api", () => {
    expect(describeHealth(null)).toBe("La API no responde.");
    expect(describeHealth({ ok: false, version: "x", commit: "y" })).toBe(
      "La API no responde.",
    );
  });

  it("shows version and short commit when online", () => {
    expect(
      describeHealth({ ok: true, version: "0.1.0", commit: "abcdef0123456" }),
    ).toBe("API en línea, versión 0.1.0 (abcdef0).");
  });
});
