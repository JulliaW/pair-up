import { createClient } from '@supabase/supabase-js'

// Estas variáveis precisarão ser definidas no ambiente ou em um arquivo .env
// Vamos expor via quasar.config.js no env, mas por enquanto usamos placeholders
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || ''
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || ''

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export default supabase