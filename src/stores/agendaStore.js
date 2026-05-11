import { defineStore } from 'pinia'
import { supabase } from 'src/services/supabaseClient'
import { useAuthStore } from './authStore'

export const useAgendaStore = defineStore('agenda', {
  state: () => ({
    events: [],
    currentMonth: new Date().getMonth(),
    currentYear: new Date().getFullYear(),
    loading: false,
    selectedDate: null
  }),

  getters: {
    eventsForDate: (state) => (date) => {
      return state.events.filter(event => event.event_date === date)
    },
    monthEvents: (state) => {
      return state.events
    },
    upcomingEvents: (state) => {
      const today = new Date().toISOString().split('T')[0]
      return state.events
        .filter(event => event.event_date >= today)
        .sort((a, b) => a.event_date.localeCompare(b.event_date))
        .slice(0, 5)
    }
  },

  actions: {
    async fetchEvents () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      this.loading = true
      try {
        const startDate = new Date(this.currentYear, this.currentMonth, 1)
          .toISOString().split('T')[0]
        const endDate = new Date(this.currentYear, this.currentMonth + 1, 0)
          .toISOString().split('T')[0]

        const { data, error } = await supabase
          .from('agenda_events')
          .select('*')
          .eq('couple_id', authStore.coupleId)
          .gte('event_date', startDate)
          .lte('event_date', endDate)
          .order('event_date', { ascending: true })
          .order('event_time', { ascending: true })

        if (error) throw error
        this.events = data || []
      } catch (err) {
        console.error('Erro ao buscar eventos:', err)
      } finally {
        this.loading = false
      }
    },

    async createEvent (event) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal vinculado' }

      try {
        const { data, error } = await supabase
          .from('agenda_events')
          .insert({
            couple_id: authStore.coupleId,
            title: event.title,
            description: event.description || null,
            event_date: event.event_date,
            event_time: event.event_time || null,
            recurrence: event.recurrence || 'none',
            responsible_user_id: event.responsible_user_id || null,
            created_by: authStore.user?.id
          })
          .select()
          .single()

        if (error) throw error

        this.events.push(data)
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao criar evento:', err)
        return { success: false, error: err.message }
      }
    },

    async updateEvent (id, updates) {
      try {
        const { data, error } = await supabase
          .from('agenda_events')
          .update(updates)
          .eq('id', id)
          .select()
          .single()

        if (error) throw error

        const index = this.events.findIndex(e => e.id === id)
        if (index !== -1) {
          this.events[index] = data
        }
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao atualizar evento:', err)
        return { success: false, error: err.message }
      }
    },

    async deleteEvent (id) {
      try {
        const { error } = await supabase
          .from('agenda_events')
          .delete()
          .eq('id', id)

        if (error) throw error

        this.events = this.events.filter(e => e.id !== id)
        return { success: true }
      } catch (err) {
        console.error('Erro ao deletar evento:', err)
        return { success: false, error: err.message }
      }
    },

    goToPreviousMonth () {
      if (this.currentMonth === 0) {
        this.currentMonth = 11
        this.currentYear--
      } else {
        this.currentMonth--
      }
      this.fetchEvents()
    },

    goToNextMonth () {
      if (this.currentMonth === 11) {
        this.currentMonth = 0
        this.currentYear++
      } else {
        this.currentMonth++
      }
      this.fetchEvents()
    },

    goToToday () {
      const today = new Date()
      this.currentMonth = today.getMonth()
      this.currentYear = today.getFullYear()
      this.fetchEvents()
    }
  }
})