<template>
  <q-page class="tasks-page">
    <!-- Topo com ações -->
    <div class="tasks-toolbar">
      <div class="toolbar-row">
        <div class="tab-switch">
          <q-btn
            flat
            dense
            :color="store.viewMode === 'kanban' ? 'primary' : 'grey-7'"
            :text-color="store.viewMode === 'kanban' ? 'primary' : 'grey-7'"
            icon="view_column"
            label="Kanban"
            size="sm"
            @click="store.setViewMode('kanban')"
          />
          <q-btn
            flat
            dense
            :color="store.viewMode === 'list' ? 'primary' : 'grey-7'"
            :text-color="store.viewMode === 'list' ? 'primary' : 'grey-7'"
            icon="list"
            label="Lista"
            size="sm"
            @click="store.setViewMode('list')"
          />
        </div>

        <q-btn
          flat
          round
          dense
          icon="filter_list"
          :color="store.hasActiveFilters ? 'primary' : 'grey-7'"
          @click="filtersOpen = !filtersOpen"
        >
          <q-tooltip>Filtros</q-tooltip>
        </q-btn>
      </div>

      <!-- Filtros expansíveis -->
      <div v-if="filtersOpen" class="filters-panel">
        <div class="filter-row">
          <q-select
            v-model="filterPriority"
            :options="priorityOptions"
            label="Prioridade"
            outlined
            dense
            clearable
            map-options
            emit-value
            class="filter-select"
            @update:model-value="store.setFilterPriority"
          />
          <q-select
            v-model="filterResponsible"
            :options="responsibleOptions"
            label="Responsável"
            outlined
            dense
            clearable
            map-options
            emit-value
            class="filter-select"
            @update:model-value="store.setFilterResponsible"
          />
        </div>
        <q-btn
          v-if="store.hasActiveFilters"
          flat
          dense
          size="sm"
          color="grey-7"
          icon="clear"
          label="Limpar filtros"
          @click="clearFilters"
        />
      </div>

      <!-- Ordenação (modo lista) -->
      <div v-if="store.viewMode === 'list'" class="sort-row">
        <span class="sort-label">Ordenar por:</span>
        <q-btn
          flat
          dense
          size="sm"
          :color="store.sortBy === 'due_date' ? 'primary' : 'grey-7'"
          :icon="
            store.sortBy === 'due_date'
              ? store.sortOrder === 'asc'
                ? 'arrow_upward'
                : 'arrow_downward'
              : ''
          "
          label="Data"
          @click="store.setSortBy('due_date')"
        />
        <q-btn
          flat
          dense
          size="sm"
          :color="store.sortBy === 'priority' ? 'primary' : 'grey-7'"
          :icon="
            store.sortBy === 'priority'
              ? store.sortOrder === 'asc'
                ? 'arrow_upward'
                : 'arrow_downward'
              : ''
          "
          label="Prioridade"
          @click="store.setSortBy('priority')"
        />
        <q-btn
          flat
          dense
          size="sm"
          :color="store.sortBy === 'created_at' ? 'primary' : 'grey-7'"
          :icon="
            store.sortBy === 'created_at'
              ? store.sortOrder === 'asc'
                ? 'arrow_upward'
                : 'arrow_downward'
              : ''
          "
          label="Criação"
          @click="store.setSortBy('created_at')"
        />
      </div>
    </div>

    <!-- Loading -->
    <div v-if="store.loading" class="loading-section">
      <q-spinner-dots size="40px" color="primary" />
    </div>

    <!-- Empty state -->
    <div v-else-if="store.tasks.length === 0" class="empty-section">
      <q-icon name="checklist" size="56px" color="grey-4" />
      <h6 class="empty-title">Nenhuma tarefa</h6>
      <p class="empty-desc">
        Adicione tarefas para organizar o dia a dia do casal
      </p>
    </div>

    <!-- Visão Kanban -->
    <div v-else-if="store.viewMode === 'kanban'" class="kanban-view">
      <div class="kanban-columns">
        <!-- A Fazer -->
        <div
          class="kanban-column"
          @dragover.prevent
          @drop.prevent="onDrop('todo')"
        >
          <div class="column-header">
            <q-icon name="radio_button_unchecked" size="18px" color="grey-6" />
            <span class="column-title">A Fazer</span>
            <span class="column-count">{{ store.todoCount }}</span>
          </div>
          <div class="column-body">
            <TaskCard
              v-for="task in store.todoTasks"
              :key="task.id"
              :task="task"
              @dragstart="onDragStart"
              @edit="openEditDialog"
              @delete="handleDelete"
            />
            <div v-if="store.todoCount === 0" class="column-empty">
              Nenhuma tarefa
            </div>
          </div>
        </div>

        <!-- Em Andamento -->
        <div
          class="kanban-column"
          @dragover.prevent
          @drop.prevent="onDrop('in_progress')"
        >
          <div class="column-header">
            <q-icon name="pending" size="18px" color="warning" />
            <span class="column-title">Em Andamento</span>
            <span class="column-count">{{ store.inProgressCount }}</span>
          </div>
          <div class="column-body">
            <TaskCard
              v-for="task in store.inProgressTasks"
              :key="task.id"
              :task="task"
              @dragstart="onDragStart"
              @edit="openEditDialog"
              @delete="handleDelete"
            />
            <div v-if="store.inProgressCount === 0" class="column-empty">
              Nenhuma tarefa
            </div>
          </div>
        </div>

        <!-- Concluídas -->
        <div
          class="kanban-column"
          @dragover.prevent
          @drop.prevent="onDrop('done')"
        >
          <div class="column-header">
            <q-icon name="check_circle" size="18px" color="positive" />
            <span class="column-title">Concluídas</span>
            <span class="column-count">{{ store.doneCount }}</span>
          </div>
          <div class="column-body">
            <TaskCard
              v-for="task in store.doneTasks"
              :key="task.id"
              :task="task"
              @dragstart="onDragStart"
              @edit="openEditDialog"
              @delete="handleDelete"
            />
            <div v-if="store.doneCount === 0" class="column-empty">
              Nenhuma tarefa
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Visão Lista -->
    <div v-else class="list-view">
      <div class="list-items">
        <TaskCard
          v-for="task in store.filteredTasks"
          :key="task.id"
          :task="task"
          @edit="openEditDialog"
          @delete="handleDelete"
        />
      </div>
    </div>

    <!-- FAB para adicionar tarefa -->
    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <q-btn fab icon="add" color="primary" @click="openAddDialog" />
    </q-page-sticky>

    <!-- Diálogo de criação/edição -->
    <q-dialog v-model="dialogOpen" persistent>
      <q-card class="task-dialog-card">
        <q-card-section class="dialog-header">
          <div class="text-h6">
            {{ isEditing ? "Editar Tarefa" : "Nova Tarefa" }}
          </div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            ref="titleInputRef"
            v-model="form.title"
            label="Título *"
            outlined
            dense
            autofocus
            :error="!!formErrors.title"
            :error-message="formErrors.title"
            class="q-mb-md"
            @keyup.enter="saveTask"
          />

          <q-input
            v-model="form.description"
            label="Descrição"
            outlined
            dense
            class="q-mb-md"
            type="textarea"
            rows="2"
          />

          <div class="row q-col-gutter-sm">
            <div class="col-6">
              <q-select
                v-model="form.priority"
                :options="priorityOptions"
                label="Prioridade"
                outlined
                dense
                map-options
                emit-value
              />
            </div>
            <div class="col-6">
              <q-input
                v-model="form.due_date"
                label="Data limite"
                outlined
                dense
                type="date"
              />
            </div>
          </div>

          <q-select
            v-model="form.responsible_user_id"
            :options="responsibleOptions"
            label="Responsável"
            outlined
            dense
            class="q-mt-md"
            clearable
            map-options
            emit-value
          />
        </q-card-section>

        <q-card-actions align="right" class="dialog-actions">
          <q-btn flat label="Cancelar" color="grey-7" v-close-popup />
          <q-btn
            flat
            label="Salvar"
            color="primary"
            :loading="saving"
            @click="saveTask"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Diálogo de exclusão -->
    <q-dialog v-model="confirmDeleteOpen" persistent>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Remover tarefa</div>
          <q-space />
          <q-btn flat round dense icon="close" v-close-popup />
        </q-card-section>

        <q-card-section>
          <p class="q-mb-none">
            Tem certeza que deseja remover
            <strong>{{ taskToDeleteName }}</strong
            >?
          </p>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="grey-7" v-close-popup />
          <q-btn
            flat
            label="Remover"
            color="negative"
            :loading="deleting"
            @click="confirmDelete"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from "vue";
import { useTasksStore } from "src/stores/tasksStore";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";
import TaskCard from "src/components/TaskCard.vue";

const $q = useQuasar();
const store = useTasksStore();
const authStore = useAuthStore();

// Filtros
const filtersOpen = ref(false);
const filterPriority = ref(null);
const filterResponsible = ref(null);

const priorityOptions = [
  { label: "Alta", value: "high" },
  { label: "Média", value: "medium" },
  { label: "Baixa", value: "low" },
];

const responsibleOptions = computed(() => {
  const options = [{ label: "Todos", value: null }];
  if (authStore.couple?.partner1_name) {
    options.push({
      label: authStore.couple.partner1_name,
      value: authStore.couple.partner1_id,
    });
  }
  if (authStore.couple?.partner2_name) {
    options.push({
      label: authStore.couple.partner2_name,
      value: authStore.couple.partner2_id,
    });
  }
  if (authStore.user) {
    const me = authStore.user;
    const already =
      authStore.couple?.partner1_id === me.id ||
      authStore.couple?.partner2_id === me.id;
    if (!already) {
      options.push({ label: me.name || "Eu", value: me.id });
    }
  }
  return options;
});

// Form state
const dialogOpen = ref(false);
const isEditing = ref(false);
const editingId = ref(null);
const saving = ref(false);
const titleInputRef = ref(null);
const form = ref({
  title: "",
  description: "",
  priority: "medium",
  due_date: "",
  responsible_user_id: null,
});
const formErrors = ref({});

// Delete state
const confirmDeleteOpen = ref(false);
const deleting = ref(false);
const taskToDeleteId = ref(null);
const taskToDeleteName = ref("");

// Drag state
const draggedTask = ref(null);

function onDragStart(event, task) {
  draggedTask.value = task;
  event.dataTransfer.effectAllowed = "move";
}

async function onDrop(status) {
  if (!draggedTask.value) return;
  if (draggedTask.value.status === status) {
    draggedTask.value = null;
    return;
  }

  const result = await store.updateTaskStatus(draggedTask.value.id, status);
  if (!result.success) {
    $q.notify({ type: "negative", message: "Erro ao mover tarefa" });
  }
  draggedTask.value = null;
}

function openAddDialog() {
  isEditing.value = false;
  editingId.value = null;
  form.value = {
    title: "",
    description: "",
    priority: "medium",
    due_date: "",
    responsible_user_id: null,
  };
  formErrors.value = {};
  dialogOpen.value = true;
  nextTick(() => {
    titleInputRef.value?.focus();
  });
}

function openEditDialog(task) {
  isEditing.value = true;
  editingId.value = task.id;
  form.value = {
    title: task.title,
    description: task.description || "",
    priority: task.priority,
    due_date: task.due_date || "",
    responsible_user_id: task.responsible_user_id || null,
  };
  formErrors.value = {};
  dialogOpen.value = true;
  nextTick(() => {
    titleInputRef.value?.focus();
  });
}

async function saveTask() {
  formErrors.value = {};
  if (!form.value.title?.trim()) {
    formErrors.value.title = "Informe o título da tarefa";
    return;
  }

  saving.value = true;
  try {
    if (isEditing.value) {
      const result = await store.updateTask(editingId.value, {
        title: form.value.title.trim(),
        description: form.value.description?.trim() || null,
        priority: form.value.priority,
        due_date: form.value.due_date || null,
        responsible_user_id: form.value.responsible_user_id || null,
      });
      if (!result.success) {
        $q.notify({ type: "negative", message: "Erro ao atualizar tarefa" });
        return;
      }
    } else {
      const result = await store.createTask({
        title: form.value.title.trim(),
        description: form.value.description?.trim() || null,
        priority: form.value.priority,
        due_date: form.value.due_date || null,
        responsible_user_id: form.value.responsible_user_id || null,
      });
      if (!result.success) {
        $q.notify({
          type: "negative",
          message: result.error || "Erro ao criar tarefa",
        });
        return;
      }
    }
    dialogOpen.value = false;
  } catch {
    $q.notify({ type: "negative", message: "Erro ao salvar tarefa" });
  } finally {
    saving.value = false;
  }
}

function handleDelete(task) {
  taskToDeleteId.value = task.id;
  taskToDeleteName.value = task.title;
  confirmDeleteOpen.value = true;
}

async function confirmDelete() {
  deleting.value = true;
  try {
    const result = await store.deleteTask(taskToDeleteId.value);
    if (result.success) {
      confirmDeleteOpen.value = false;
    } else {
      $q.notify({ type: "negative", message: "Erro ao remover tarefa" });
    }
  } catch {
    $q.notify({ type: "negative", message: "Erro ao remover tarefa" });
  } finally {
    deleting.value = false;
  }
}

function clearFilters() {
  filterPriority.value = null;
  filterResponsible.value = null;
  store.clearFilters();
}

// Inicialização
onMounted(async () => {
  if (authStore.couple?.id) {
    await store.fetchTasks();
  }
});

authStore.$subscribe(async (mutation, state) => {
  if (state.couple?.id && store.tasks.length === 0) {
    await store.fetchTasks();
  }
});
</script>

<style scoped lang="scss">
.tasks-page {
  padding: 0;
  background: var(--background);
  min-height: 100vh;
  padding-bottom: 80px;

  display: flex;
  flex-direction: column;
}

.tasks-toolbar {
  padding: 8px 16px;
  background: var(--background);
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.toolbar-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.tab-switch {
  display: flex;
  gap: 4px;
  background: rgba(0, 0, 0, 0.04);
  border-radius: 8px;
  padding: 2px;
}

.filters-panel {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-row {
  display: flex;
  gap: 8px;
}

.filter-select {
  flex: 1;
}

.sort-row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.sort-label {
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-right: 4px;
}

/* Loading & Empty */
.loading-section {
  display: flex;
  justify-content: center;
  padding: 64px 0;
}

.empty-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64px 24px;
  text-align: center;
}

.empty-title {
  margin: 16px 0 4px;
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--text-primary);
}

.empty-desc {
  font-size: 0.875rem;
  color: var(--text-muted);
  margin: 0;
}

/* Kanban View */
.kanban-view {
  flex: 1;
  overflow-x: auto;
  padding: 0 12px 16px;
}

.kanban-columns {
  display: flex;
  gap: 12px;
  min-height: 200px;
  align-items: flex-start;
}

.kanban-column {
  flex: 1;
  min-width: 250px;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 14px;
  border: 1px solid var(--separator);
  overflow: hidden;
}

.column-header {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 12px;
  border-bottom: 1px solid var(--separator);
}

.column-title {
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--text-primary);
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.column-count {
  margin-left: auto;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-muted);
  background: rgba(0, 0, 0, 0.05);
  padding: 0 8px;
  border-radius: 10px;
  line-height: 1.6;
}

.column-body {
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-height: 80px;
}

.column-empty {
  text-align: center;
  padding: 24px 8px;
  font-size: 0.8125rem;
  color: var(--text-muted);
}

/* List View */
.list-view {
  padding: 0 16px 16px;
}

.list-items {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Dialog */
.task-dialog-card {
  border-radius: 20px;
  max-width: 420px;
  width: 100%;
}

.dialog-header {
  padding-bottom: 8px;
}
</style>
