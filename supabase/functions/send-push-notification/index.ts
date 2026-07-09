// Supabase Edge Function: send-push-notification
// Dipanggil oleh Database Webhook saat ada INSERT ke tabel notifications
// Mengirim push notification via FCM HTTP v1 API menggunakan Service Account

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// Ambil env vars yang sudah disimpan di Supabase Secrets
const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;
const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL")!;
const FCM_PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY")!.replace(/\\n/g, "\n");

// ── Helper: buat JWT untuk autentikasi ke Google FCM API ──────────────────────
async function createJwt(): Promise<string> {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: FCM_CLIENT_EMAIL,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  const signingInput = `${encode(header)}.${encode(payload)}`;

  // Import private key RSA
  const keyData = FCM_PRIVATE_KEY
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  );

  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  return `${signingInput}.${sigB64}`;
}

// ── Helper: tukar JWT dengan OAuth2 access token ─────────────────────────────
async function getAccessToken(): Promise<string> {
  const jwt = await createJwt();
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!data.access_token) throw new Error(`OAuth2 error: ${JSON.stringify(data)}`);
  return data.access_token;
}

// ── Helper: kirim satu FCM push notification ──────────────────────────────────
async function sendFcmNotification(
  token: string,
  title: string,
  body: string,
  ticketId?: string
): Promise<void> {
  const accessToken = await getAccessToken();

  const message: Record<string, unknown> = {
    token,
    notification: { title, body },
    android: {
      priority: "high",
      notification: {
        channel_id: "eticketing_channel",
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: { alert: { title, body }, sound: "default", badge: 1 },
      },
    },
  };

  // Sertakan ticket_id sebagai data payload untuk navigasi saat tap
  if (ticketId) {
    message.data = { ticket_id: ticketId };
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message }),
    }
  );

  const result = await res.json();
  if (!res.ok) {
    console.error("FCM send error:", JSON.stringify(result));
  } else {
    console.log("FCM sent successfully:", result.name);
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────
serve(async (req) => {
  try {
    const body = await req.json();
    console.log("Webhook payload received:", JSON.stringify(body));

    // Supabase Database Webhook mengirim data di body.record
    const record = body.record ?? body;

    const userId: string = record.user_id;
    const title: string = record.title ?? "Notifikasi";
    const message: string = record.message ?? "";
    const ticketId: string | undefined = record.ticket_id;

    if (!userId) {
      return new Response(JSON.stringify({ error: "user_id missing" }), { status: 400 });
    }

    // Ambil FCM token dari tabel profiles di Supabase
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const profileRes = await fetch(
      `${SUPABASE_URL}/rest/v1/profiles?id=eq.${userId}&select=fcm_token`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      }
    );

    const profiles = await profileRes.json();
    const fcmToken: string | null = profiles?.[0]?.fcm_token ?? null;

    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}, skipping push.`);
      return new Response(JSON.stringify({ skipped: true, reason: "no fcm_token" }), {
        status: 200,
      });
    }

    await sendFcmNotification(fcmToken, title, message, ticketId);

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
