import { defineStore } from 'pinia'
import { supabase } from 'src/services/supabaseClient'
import { useAuthStore } from './authStore'

export const useShoppingStore = defineStore('shopping', {
  state: () => ({
    currentMonth: new Date().getMonth() + 1,
    currentYear: new Date().getFullYear(),
    months: [],
    items: [],
    loading: false,
    rolloverLoading: false
  }),

  getters: {
    currentMonthId: (state) => {
      const match = state.months.find(
        m => m.month === state.currentMonth && m.year === state.currentYear
      )
      return match?.id || null
    },

    currentMonthData: (state) => {
      return state.months.find(
        m => m.month === state.currentMonth && m.year === state.currentYear
      ) || null
    },

    itemsByCategory: (state) => {
      const grouped = {}
      const itens = state.items || []

      itens.forEach(item => {
        const cat = item.category || 'Sem categoria'
        if (!grouped[cat]) {
          grouped[cat] = { name: cat, items: [] }
        }
        grouped[cat].items.push(item)
      })

      // Ordenar categorias: as que têm itens pendentes primeiro, depois alfabeticamente
      return Object.values(grouped).sort((a, b) => {
        const aHasPending = a.items.some(i => i.status === 'pending')
        const bHasPending = b.items.some(i => i.status === 'pending')
        if (aHasPending && !bHasPending) return -1
        if (!aHasPending && bHasPending) return 1
        return a.name.localeCompare(b.name)
      })
    },

    pendingItems: (state) => {
      return (state.items || []).filter(i => i.status === 'pending')
    },

    purchasedItems: (state) => {
      return (state.items || []).filter(i => i.status === 'purchased')
    },

    totalItems: (state) => {
      return (state.items || []).length
    },

    purchasedCount: (state) => {
      return (state.items || []).filter(i => i.status === 'purchased').length
    },

    progress: (state) => {
      const total = (state.items || []).length
      if (total === 0) return 0
      const purchased = (state.items || []).filter(i => i.status === 'purchased').length
      return Math.round((purchased / total) * 100)
    },

    currentMonthLabel: (state) => {
      const months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ]
      return `${months[state.currentMonth - 1]} ${state.currentYear}`
    }
  },

  actions: {
    async fetchMonths () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      try {
        const { data, error } = await supabase
          .from('shopping_months')
          .select('*')
          .eq('couple_id', authStore.coupleId)
          .order('year', { ascending: false })
          .order('month', { ascending: false })

        if (error) throw error
        this.months = data || []
      } catch (err) {
        console.error('Erro ao buscar meses de compras:', err)
      }
    },

    async ensureCurrentMonth () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return null

      // Se já existe, retorna o ID
      const existing = this.months.find(
        m => m.month === this.currentMonth && m.year === this.currentYear
      )
      if (existing) return existing.id

      // Cria o mês
      try {
        const { data, error } = await supabase
          .from('shopping_months')
          .insert({
            couple_id: authStore.coupleId,
            month: this.currentMonth,
            year: this.currentYear
          })
          .select()
          .single()

        if (error) throw error
        this.months.unshift(data)
        return data.id
      } catch (err) {
        console.error('Erro ao criar mês de compras:', err)
        return null
      }
    },

    async fetchItems () {
      const monthId = await this.ensureCurrentMonth()
      if (!monthId) return

      this.loading = true
      try {
        const { data, error } = await supabase
          .from('shopping_items')
          .select('id, name, quantity, category, notes, status, purchased_by, purchased_at, created_at')
          .eq('shopping_month_id', monthId)
          .order('created_at', { ascending: true })

        if (error) throw error
        this.items = data || []
      } catch (err) {
        console.error('Erro ao buscar itens de compras:', err)
      } finally {
        this.loading = false
      }
    },

    async createItem ({ name, quantity = 1, category = null, notes = null }) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal vinculado' }

      const monthId = await this.ensureCurrentMonth()
      if (!monthId) return { success: false, error: 'Erro ao criar mês' }

      if (!name || !name.trim()) return { success: false, error: 'Nome é obrigatório' }

      try {
        const { data, error } = await supabase
          .from('shopping_items')
          .insert({
            shopping_month_id: monthId,
            name: name.trim(),
            quantity: quantity || 1,
            category: category || null,
            notes: notes || null,
            status: 'pending'
          })
          .select()
          .single()

        if (error) throw error

        this.items.push(data)

        // Atualiza contadores no mês
        this.updateMonthCounters()

        return { success: true, data }
      } catch (err) {
        console.error('Erro ao criar item de compra:', err)
        return { success: false, error: err.message }
      }
    },

    async toggleItemStatus (item) {
      const authStore = useAuthStore()
      const newStatus = item.status === 'purchased' ? 'pending' : 'purchased'

      try {
        const updates = {
          status: newStatus,
          purchased_by: newStatus === 'purchased' ? authStore.user?.id : null,
          purchased_at: newStatus === 'purchased' ? new Date().toISOString() : null
        }

        const { data, error } = await supabase
          .from('shopping_items')
          .update(updates)
          .eq('id', item.id)
          .select()
          .single()

        if (error) throw error

        const idx = this.items.findIndex(i => i.id === item.id)
        if (idx !== -1) {
          this.items[idx] = data
        }

        this.updateMonthCounters()

        return { success: true, data }
      } catch (err) {
        console.error('Erro ao atualizar item:', err)
        return { success: false, error: err.message }
      }
    },

    async updateItem (id, updates) {
      try {
        const { data, error } = await supabase
          .from('shopping_items')
          .update(updates)
          .eq('id', id)
          .select()
          .single()

        if (error) throw error

        const idx = this.items.findIndex(i => i.id === id)
        if (idx !== -1) {
          this.items[idx] = data
        }

        return { success: true, data }
      } catch (err) {
        console.error('Erro ao atualizar item:', err)
        return { success: false, error: err.message }
      }
    },

    async deleteItem (id) {
      try {
        const { error } = await supabase
          .from('shopping_items')
          .delete()
          .eq('id', id)

        if (error) throw error

        this.items = this.items.filter(i => i.id !== id)
        this.updateMonthCounters()

        return { success: true }
      } catch (err) {
        console.error('Erro ao deletar item:', err)
        return { success: false, error: err.message }
      }
    },

    async rolloverItems () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal' }

      this.rolloverLoading = true

      try {
        const pendingItems = this.items.filter(i => i.status === 'pending')
        if (pendingItems.length === 0) {
          this.rolloverLoading = false
          return { success: true, message: 'Nenhum item pendente para transferir' }
        }

        // Avança para o próximo mês
        this.goToNextMonth()

        // Garante que o mês existe
        const monthId = await this.ensureCurrentMonth()
        if (!monthId) throw new Error('Erro ao criar mês destino')

        // Insere os itens pendentes no novo mês
        const inserts = pendingItems.map(item => ({
          shopping_month_id: monthId,
          name: item.name,
          quantity: item.quantity || 1,
          category: item.category || null,
          notes: item.notes || null,
          status: 'pending'
        }))

        const { data, error } = await supabase
          .from('shopping_items')
          .insert(inserts)
          .select()

        if (error) throw error

        // Recarrega os itens do novo mês
        await this.fetchItems()

        this.updateMonthCounters()
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao transferir itens:', err)
        return { success: false, error: err.message }
      } finally {
        this.rolloverLoading = false
      }
    },

    async updateMonthCounters () {
      const monthId = this.currentMonthId
      if (!monthId) return

      const totalItems = (this.items || []).length
      const purchasedItems = (this.items || []).filter(i => i.status === 'purchased').length

      try {
        await supabase
          .from('shopping_months')
          .update({
            total_items: totalItems,
            purchased_items: purchasedItems
          })
          .eq('id', monthId)

        // Atualiza local
        const month = this.months.find(m => m.id === monthId)
        if (month) {
          month.total_items = totalItems
          month.purchased_items = purchasedItems
        }
      } catch (err) {
        console.error('Erro ao atualizar contadores:', err)
      }
    },

    changeMonth (month, year) {
      this.currentMonth = month
      this.currentYear = year
      this.fetchItems()
    },

    async goToNextMonth () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      const pendingItems = this.items.filter(i => i.status === 'pending')
      if (pendingItems.length > 0) {
        // Avança o mês
        if (this.currentMonth === 12) {
          this.currentMonth = 1
          this.currentYear++
        } else {
          this.currentMonth++
        }

        // Garante que o mês destino existe
        const monthId = await this.ensureCurrentMonth()
        if (monthId) {
          // Insere os itens pendentes no novo mês
          const inserts = pendingItems.map(item => ({
            shopping_month_id: monthId,
            name: item.name,
            quantity: item.quantity || 1,
            category: item.category || null,
            notes: item.notes || null,
            status: 'pending'
          }))

          await supabase
            .from('shopping_items')
            .insert(inserts)
        }
      } else {
        // Avança o mês sem rollover
        if (this.currentMonth === 12) {
          this.currentMonth = 1
          this.currentYear++
        } else {
          this.currentMonth++
        }
      }

      // Carrega os itens do novo mês
      await this.fetchItems()
    },

    goToPreviousMonth () {
      if (this.currentMonth === 1) {
        this.currentMonth = 12
        this.currentYear--
      } else {
        this.currentMonth--
      }
      this.fetchItems()
    },

    goToCurrentMonth () {
      const today = new Date()
      this.currentMonth = today.getMonth() + 1
      this.currentYear = today.getFullYear()
      this.fetchItems()
    },

    async initialize () {
      await this.fetchMonths()
      await this.fetchItems()
    }
  }
})