// Supabase Edge Function: validates an invite code without exposing service-role credentials.
// Deploy with Supabase CLI. Configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY as function secrets.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { crypto } from 'https://deno.land/std@0.224.0/crypto/mod.ts';
import { encodeHex } from 'https://deno.land/std@0.224.0/encoding/hex.ts';
const corsHeaders = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type', 'Access-Control-Allow-Methods': 'POST, OPTIONS' };
async function sha256(value: string) { return encodeHex(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))); }
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return new Response(JSON.stringify({ message: 'Method not allowed.' }), { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  try {
    const { email, inviteCode } = await req.json();
    if (typeof email !== 'string' || typeof inviteCode !== 'string' || inviteCode.length < 6 || inviteCode.length > 120) throw new Error('Invalid request.');
    const url = Deno.env.get('SUPABASE_URL'); const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!url || !key) throw new Error('Server configuration missing.');
    const admin = createClient(url, key, { auth: { persistSession: false } });
    const code_hash = await sha256(inviteCode.trim());
    const { data: invite, error: lookupError } = await admin.from('invite_codes').select('id,email,role,expires_at,redeemed_at').eq('code_hash', code_hash).maybeSingle();
    if (lookupError || !invite || invite.redeemed_at || new Date(invite.expires_at) < new Date() || invite.email.toLowerCase() !== email.toLowerCase()) {
      return new Response(JSON.stringify({ message: 'Invite is invalid, expired, already used, or assigned to another email.' }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    // Send a magic link; user must verify email before contributing.
    const { error: linkError } = await admin.auth.admin.generateLink({ type: 'magiclink', email, options: { redirectTo: Deno.env.get('SITE_URL') || undefined } });
    if (linkError) throw linkError;
    // Marking redeemed immediately is intentionally conservative. For production, redeem after auth verification via a second server-side step.
    const { error: markError } = await admin.from('invite_codes').update({ redeemed_at: new Date().toISOString() }).eq('id', invite.id).is('redeemed_at', null);
    if (markError) throw markError;
    return new Response(JSON.stringify({ message: 'Invite accepted. If your Supabase email template is configured, check your inbox for a sign-in link.' }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ message: 'Unable to process invite. Check the server setup.' }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }
});
