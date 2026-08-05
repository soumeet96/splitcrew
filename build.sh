#!/bin/sh
# Swaps the placeholder tokens in index.html for the real Supabase credentials,
# which Cloudflare provides as environment variables at build time.
sed -i "s|__SUPABASE_URL__|$SUPABASE_URL|g" index.html
sed -i "s|__SUPABASE_ANON_KEY__|$SUPABASE_ANON_KEY|g" index.html
