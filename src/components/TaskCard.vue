<template>
  <div
    class="task-card"
    :class="[
      `priority-${task.priority}`,
      { 'is-done': task.status === 'done' },
    ]"
    draggable="true"
    @dragstart="$emit('dragstart', $event, task)"
  >
    <div class="task-header">
      <span class="task-priority-dot" :class="`dot-${task.priority}`" />
      <span class="task-title">{{ task.title }}</span>
    </div>

    <div v-if="task.description" class="task-description">
      {{ task.description }}
    </div>

    <div class="task-footer">
      <div
        v-if="task.due_date"
        class="task-date"
        :class="{ overdue: isOverdue }"
      >
        <q-icon name="calendar_today" size="14px" />
        <span>{{ formatDate(task.due_date) }}</span>
      </div>

      <div class="task-actions">
        <q-btn
          flat
          round
          dense
          size="sm"
          icon="edit"
          color="grey-6"
          @click.stop="$emit('edit', task)"
        >
          <q-tooltip>Editar</q-tooltip>
        </q-btn>
        <q-btn
          flat
          round
          dense
          size="sm"
          icon="delete"
          color="grey-5"
          @click.stop="$emit('delete', task)"
        >
          <q-tooltip>Remover</q-tooltip>
        </q-btn>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
});

defineEmits(["dragstart", "edit", "delete"]);

const today = new Date().toISOString().split("T")[0];
const isOverdue =
  props.task.due_date &&
  props.task.due_date < today &&
  props.task.status !== "done";

function formatDate(dateStr) {
  if (!dateStr) return "";
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit" });
}
</script>

<style scoped lang="scss">
.task-card {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 12px;
  padding: 12px;
  cursor: grab;
  transition:
    box-shadow 0.2s,
    transform 0.2s;

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  }

  &:active {
    cursor: grabbing;
  }

  &.is-done {
    opacity: 0.7;
  }
}

.task-header {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.task-priority-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-top: 5px;
  flex-shrink: 0;

  &.dot-high {
    background: #ef4444;
  }
  &.dot-medium {
    background: #f59e0b;
  }
  &.dot-low {
    background: #22c55e;
  }
}

.task-title {
  font-size: 0.9375rem;
  font-weight: 500;
  color: var(--text-primary);
  line-height: 1.3;
}

.task-description {
  font-size: 0.8125rem;
  color: var(--text-secondary);
  margin: 6px 0 0 16px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.task-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
}

.task-date {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  color: var(--text-muted);

  &.overdue {
    color: #ef4444;
    font-weight: 600;
  }
}

.task-actions {
  display: flex;
  gap: 2px;
}
</style>
