<template>
  <div
    class="shopping-item"
    :class="{ 'is-purchased': item.status === 'purchased' }"
  >
    <q-checkbox
      :model-value="item.status === 'purchased'"
      :color="item.status === 'purchased' ? 'positive' : 'grey'"
      keep-color
      dense
      size="sm"
      @update:model-value="$emit('toggle', item)"
    />

    <div class="item-info" @click="$emit('edit', item)">
      <div class="item-name-row">
        <span class="item-name">{{ item.name }}</span>
        <span v-if="item.quantity > 1" class="item-quantity">
          x{{ item.quantity }}
        </span>
      </div>
      <div v-if="item.notes" class="item-notes">{{ item.notes }}</div>
    </div>

    <q-btn
      flat
      round
      dense
      size="sm"
      icon="delete"
      color="grey-5"
      @click="$emit('delete', item.id)"
    >
      <q-tooltip>Remover</q-tooltip>
    </q-btn>
  </div>
</template>

<script setup>
defineProps({
  item: {
    type: Object,
    required: true,
  },
});

defineEmits(["toggle", "edit", "delete"]);
</script>

<style scoped lang="scss">
.shopping-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 10px 8px;
  border-radius: 10px;
  transition: background 0.2s;
  cursor: default;

  &:hover {
    background: rgba(0, 0, 0, 0.03);
  }

  &.is-purchased {
    .item-name {
      text-decoration: line-through;
      color: var(--text-muted);
    }
    .item-quantity {
      color: var(--text-muted);
    }
    .item-notes {
      color: var(--text-muted);
    }
  }
}

.item-info {
  flex: 1;
  min-width: 0;
  cursor: pointer;
  padding: 2px 0;
}

.item-name-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.item-name {
  font-size: 0.9375rem;
  font-weight: 500;
  color: var(--text-primary);
}

.item-quantity {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-secondary);
  background: rgba(0, 0, 0, 0.05);
  padding: 0 6px;
  border-radius: 6px;
  line-height: 1.4;
}

.item-notes {
  font-size: 0.75rem;
  color: var(--text-secondary);
  margin-top: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
