import { defineStore } from 'pinia'
import { supabase } from 'src/services/supabaseClient'
import { useAuthStore } from './authStore'

export const useTasksStore = defineStore('tasks', {
  state: () => ({
    tasks: [],
    loading: false,
    viewMode: 'kanban', // 'kanban' | 'list'
    filterPriority: null, // null | 'low' | 'medium' | 'high'
    filterResponsible: null, // null | user_id
    sortBy: 'due_date', // 'due_date' | 'priority' | 'created_at'
    sortOrder: 'asc'
  }),

  getters: {
    filteredTasks: (state) => {
      let result = [...state.tasks]

      // Filtro por prioridade
      if (state.filterPriority) {
        result = result.filter(t => t.priority === state.filterPriority)
      }

      // Filtro por responsável
      if (state.filterResponsible) {
        result = result.filter(t => t.responsible_user_id === state.filterResponsible)
      }

      // Ordenação
      result.sort((a, b) => {
        const order = state.sortOrder === 'asc' ? 1 : -1
        const aVal = a[state.sortBy] || ''
        const bVal = b[state.sortBy] || ''
        if (aVal < bVal) return -1 * order
        if (aVal > bVal) return 1 * order
        return 0
      })

      return result
    },

    todoTasks: (state) => {
      return (state.tasks || []).filter(t => t.status === 'todo')
        .sort((a, b) => priorityWeight(a) - priorityWeight(b))
    },

    inProgressTasks: (state) => {
      return (state.tasks || []).filter(t => t.status === 'in_progress')
        .sort((a, b) => priorityWeight(a) - priorityWeight(b))
    },

    doneTasks: (state) => {
      return (state.tasks || []).filter(t => t.status === 'done')
        .sort((a, b) => priorityWeight(a) - priorityWeight(b))
    },

    hasActiveFilters: (state) => {
      return !!state.filterPriority || !!state.filterResponsible
    },

    totalTasks: (state) => (state.tasks || []).length,
    todoCount: (state) => (state.tasks || []).filter(t => t.status === 'todo').length,
    inProgressCount: (state) => (state.tasks || []).filter(t => t.status === 'in_progress').length,
    doneCount: (state) => (state.tasks || []).filter(t => t.status === 'done').length
  },

  actions: {
    async fetchTasks () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      this.loading = true
      try {
        const { data, error } = await supabase
          .from('tasks')
          .select('id, title, description, priority, status, due_date, responsible_user_id, created_by, created_at')
          .eq('couple_id', authStore.coupleId)
          .order('created_at', { ascending: false })

        if (error) throw error
        this.tasks = data || []
      } catch (err) {
        console.error('Erro ao buscar tarefas:', err)
      } finally {
        this.loading = false
      }
    },

    async createTask ({ title, description = null, priority = 'medium', due_date = null, responsible_user_id = null }) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal vinculado' }
      if (!title || !title.trim()) return { success: false, error: 'Título é obrigatório' }

      try {
        const { data, error } = await supabase
          .from('tasks')
          .insert({
            couple_id: authStore.coupleId,
            title: title.trim(),
            description: description?.trim() || null,
            priority,
            due_date: due_date || null,
            responsible_user_id: responsible_user_id || null,
            status: 'todo',
            created_by: authStore.user?.id
          })
          .select()
          .single()

        if (error) throw error
        this.tasks.unshift(data)
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao criar tarefa:', err)
        return { success: false, error: err.message }
      }
    },

    async updateTaskStatus (id, status) {
      try {
        const { data, error } = await supabase
          .from('tasks')
          .update({ status })
          .eq('id', id)
          .select()
          .single()

        if (error) throw error
        const idx = this.tasks.findIndex(t => t.id === id)
        if (idx !== -1) this.tasks[idx] = data
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao atualizar status da tarefa:', err)
        return { success: false, error: err.message }
      }
    },

    async updateTask (id, updates) {
      try {
        const { data, error } = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', id)
          .select()
          .single()

        if (error) throw error
        const idx = this.tasks.findIndex(t => t.id === id)
        if (idx !== -1) this.tasks[idx] = data
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao atualizar tarefa:', err)
        return { success: false, error: err.message }
      }
    },

    async deleteTask (id) {
      try {
        const { error } = await supabase
          .from('tasks')
          .delete()
          .eq('id', id)

        if (error) throw error
        this.tasks = this.tasks.filter(t => t.id !== id)
        return { success: true }
      } catch (err) {
        console.error('Erro ao deletar tarefa:', err)
        return { success: false, error: err.message }
      }
    },

    setViewMode (mode) {
      this.viewMode = mode
    },

    setFilterPriority (priority) {
      this.filterPriority = priority
    },

    setFilterResponsible (userId) {
      this.filterResponsible = userId
    },

    clearFilters () {
      this.filterPriority = null
      this.filterResponsible = null
    },

    setSortBy (field) {
      if (this.sortBy === field) {
        this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortBy = field
        this.sortOrder = 'asc'
      }
    }
  }
})

function priorityWeight (task) {
  const map = { high: 0, medium: 1, low: 2 }
  return map[task.priority] !== undefined ? map[task.priority] : 1
}