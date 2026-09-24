const { createClient } = require("@supabase/supabase-js")

const supabaseURL = process.env.SUPABASE_URL
const supabasePublicKey = process.env.SUPABASE_KEY

if (!supabaseURL) {
  throw new Error("Missing required environment variable: SUPABASE_URL");
}

if (!supabasePublicKey) {
  throw new Error("Missing required environment variable: SUPABASE_KEY");
}

const supabase = createClient(supabaseURL, supabasePublicKey)

module.exports = supabase