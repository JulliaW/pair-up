import { defineStore } from 'pinia'
import { supabase } from 'src/services/supabaseClient'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    couple: null,
    loading: false,
    initializing: true
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    coupleId: (state) => state.couple?.id || null,
    partner1: (state) => state.couple?.partner1 || null,
    partner2: (state) => state.couple?.partner2 || null,
    isPartnerComplete: (state) => !!state.couple?.partner1 && !!state.couple?.partner2
  },

  actions: {
    async initialize () {
      this.initializing = true
      try {
        const { data: { session } } = await supabase.auth.getSession()
        if (session?.user) {
          await this.fetchUserData(session.user.id)
        }
      } catch (err) {
        console.error('Erro ao inicializar auth:', err)
      } finally {
        this.initializing = false
      }
    },

    async fetchUserData (userId) {
      if (!userId) return

      // Busca dados do usuário
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle()

      if (userError || !userData) {
        console.error('Erro ao buscar dados do usuário:', userError)
        return
      }

      this.user = {
        id: userData.id,
        email: userData.email,
        name: userData.name,
        avatarUrl: userData.avatar_url
      }

      // Busca dados do casal separadamente
      if (userData.couple_id) {
        const { data: coupleData, error: coupleError } = await supabase
          .from('couples')
          .select('*')
          .eq('id', userData.couple_id)
          .maybeSingle()

        if (!coupleError && coupleData) {
          this.couple = coupleData
        }
      }
    },

    async register (email, password, name) {
      this.loading = true
      try {
        // 1. Criar usuário no Supabase Auth
        const { data: authData, error: authError } = await supabase.auth.signUp({
          email,
          password
        })

        if (authError) throw authError

        if (!authData.user) throw new Error('Erro ao criar usuário')

        // 2. O trigger handle_new_user já criou o registro em users
        //    Agora só atualizamos o nome
        const { error: updateNameError } = await supabase
          .from('users')
          .update({ name })
          .eq('id', authData.user.id)

        if (updateNameError) throw updateNameError

        // 3. Criar couple (casal) e vincular partner1
        const { data: coupleData, error: coupleError } = await supabase
          .from('couples')
          .insert({
            partner1_id: authData.user.id,
            invite_code: this.generateInviteCode()
          })
          .select()
          .single()

        if (coupleError) throw coupleError

        // 4. Atualizar user com couple_id
        const { error: updateError } = await supabase
          .from('users')
          .update({ couple_id: coupleData.id })
          .eq('id', authData.user.id)

        if (updateError) throw updateError

        await this.fetchUserData(authData.user.id)

        return { success: true, inviteCode: coupleData.invite_code }
      } catch (err) {
        console.error('Erro no registro:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async login (email, password) {
      this.loading = true
      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        })

        if (error) throw error
        if (data?.user) {
          await this.fetchUserData(data.user.id)
        }

        return { success: true }
      } catch (err) {
        console.error('Erro no login:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async logout () {
      try {
        await supabase.auth.signOut()
        this.user = null
        this.couple = null
      } catch (err) {
        console.error('Erro no logout:', err)
      }
    },

    async acceptInvite (inviteCode) {
      this.loading = true
      try {
        if (!this.user) throw new Error('Usuário não autenticado')

        // Buscar couple pelo código
        const { data: coupleData, error: coupleError } = await supabase
          .from('couples')
          .select('*')
          .eq('invite_code', inviteCode)
          .is('partner2_id', null)
          .single()

        if (coupleError || !coupleData) {
          throw new Error('Código de convite inválido ou já utilizado')
        }

        // Atualizar couple com partner2
        const { error: updateCoupleError } = await supabase
          .from('couples')
          .update({ partner2_id: this.user.id })
          .eq('id', coupleData.id)

        if (updateCoupleError) throw updateCoupleError

        // Atualizar user com couple_id
        const { error: updateUserError } = await supabase
          .from('users')
          .update({ couple_id: coupleData.id })
          .eq('id', this.user.id)

        if (updateUserError) throw updateUserError

        await this.fetchUserData(this.user.id)

        return { success: true }
      } catch (err) {
        console.error('Erro ao aceitar convite:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    generateInviteCode () {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      let code = ''
      for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length))
      }
      return code
    },

    async sendInviteEmail (email) {
      try {
        if (!this.couple?.invite_code) {
          throw new Error('Código de convite não encontrado')
        }

        // Envia email com código de convite via função Supabase
        const { error } = await supabase.functions.invoke('send-invite', {
          body: {
            to: email,
            inviteCode: this.couple.invite_code,
            partnerName: this.user?.name
          }
        })

        if (error) throw error
        return { success: true }
      } catch (err) {
        console.error('Erro ao enviar convite:', err)
        return { success: false, error: err.message }
      }
    }
  }
})