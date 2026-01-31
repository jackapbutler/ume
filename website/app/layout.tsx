import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "UMe - AI Dating Companion | Stop Swiping, Start Connecting",
  description: "Meet UMe, your AI companion for meaningful dating. No endless swiping, just deep connections and guided conversations. Experience dating wellness by design.",
  keywords: "AI dating, meaningful connections, dating companion, no swiping, dating wellness, guided conversations",
  authors: [{ name: "UMe Team" }],
  creator: "UMe",
  publisher: "UMe",
  robots: "index, follow",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://ume-dating.com",
    title: "UMe - AI Dating Companion",
    description: "Stop swiping. Start connecting with your AI dating companion.",
    siteName: "UMe",
  },
  twitter: {
    card: "summary_large_image",
    title: "UMe - AI Dating Companion",
    description: "Stop swiping. Start connecting with your AI dating companion.",
    creator: "@ume_dating",
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  themeColor: '#3b82f6',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link rel="icon" href="/icon.ico" />
        <meta name="color-scheme" content="dark light" />
      </head>
      <body className={`${inter.className} antialiased`}>
        <div id="main-content" className="min-h-screen">
          {children}
        </div>
      </body>
    </html>
  );
}
