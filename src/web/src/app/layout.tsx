import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Autofacturación",
  description: "Portal de autofacturación para clientes de CONTPAQi Comercial Pro",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="es-MX" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
