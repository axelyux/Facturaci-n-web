import { expect, test } from "@playwright/test";

test("la página de inicio carga sin scroll horizontal", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Autofacturación" })).toBeVisible();
  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth > document.documentElement.clientWidth,
  );
  expect(overflow).toBe(false);
});
