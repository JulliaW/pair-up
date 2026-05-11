import { boot } from 'quasar/wrappers'
import { supabase } from 'src/services/supabaseClient'
import { useAuthStore } from 'src/stores/authStore'

// Este boot escuta mudanças de autenticação em tempo real
export default boot((/* { app } */) => {
  const authStore = useAuthStore()

  // Inicializa o estado de autenticação
  authStore.initialize()

  // Escuta mudanças na sessão (login/logout/refresh)
  supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN' && session?.user) {
      authStore.fetchUserData(session.user.id)
    } else if (event === 'SIGNED_OUT') {
      authStore.user = null
      authStore.couple = null
    }
  })
})