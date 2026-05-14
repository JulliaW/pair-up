<template>
  <q-page class="shopping-page">
    <!-- Cabeçalho com navegação de meses -->
    <div class="shopping-header">
      <div class="month-navigation">
        <q-btn
          flat
          round
          dense
          icon="chevron_left"
          color="grey-7"
          @click="store.goToPreviousMonth()"
        />
        <div class="month-title" @click="store.goToCurrentMonth()">
          <span class="month-name">{{ store.currentMonthLabel }}</span>
          <q-icon
            name="calendar_today"
            size="16px"
            class="q-ml-xs"
            color="grey-5"
          />
        </div>
        <q-btn
          flat
          round
          dense
          icon="chevron_right"
          color="grey-7"
          @click="store.goToNextMonth()"
        />
      </div>
    </div>

    <!-- Barra de Progresso -->
    <div class="progress-section">
      <div class="progress-header">
        <span class="progress-label">Progresso da lista</span>
        <span class="progress-percent">{{ store.progress }}%</span>
      </div>
      <q-linear-progress
        :value="store.progress / 100"
        size="10px"
        rounded
        color="positive"
        track-color="grey-3"
        class="progress-bar"
      />
      <div class="progress-stats">
        <span
          >{{ store.purchasedCount }} de {{ store.totalItems }} itens
          comprados</span
        >
      </div>
    </div>

    <!-- Conteúdo principal -->
    <div v-if="store.loading" class="loading-section">
      <q-spinner-dots size="40px" color="primary" />
    </div>

    <div v-else-if="store.totalItems === 0" class="empty-section">
      <q-icon name="shopping_cart" size="56px" color="grey-4" />
      <h6 class="empty-title">Lista vazia</h6>
      <p class="empty-desc">Adicione itens à lista de compras deste mês</p>
    </div>

    <div v-else class="items-list">
      <div
        v-for="group in store.itemsByCategory"
        :key="group.name"
        class="category-group"
      >
        <div class="category-header">
          <q-icon
            :name="getCategoryIcon(group.name)"
            size="18px"
            color="grey-6"
          />
          <span class="category-name">{{ group.name }}</span>
          <span class="category-count">
            {{ group.items.filter((i) => i.status === "pending").length }}
            pendente{{
              group.items.filter((i) => i.status === "pending").length !== 1
                ? "s"
                : ""
            }}
          </span>
        </div>

        <div class="category-items">
          <ShoppingItem
            v-for="item in group.items"
            :key="item.id"
            :item="item"
            @toggle="handleToggle"
            @edit="openEditDialog"
            @delete="handleDelete"
          />
        </div>
      </div>
    </div>

    <!-- FAB para adicionar item -->
    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <q-btn fab icon="add" color="primary" @click="openAddDialog" />
    </q-page-sticky>

    <!-- Diálogo para adicionar/editar item -->
    <q-dialog v-model="dialogOpen" persistent>
      <q-card class="item-dialog-card">
        <q-card-section class="dialog-header">
          <div class="text-h6">
            {{ isEditing ? "Editar Item" : "Novo Item" }}
          </div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            ref="nameInputRef"
            v-model="form.name"
            label="Nome do item *"
            outlined
            dense
            autofocus
            :error="!!formErrors.name"
            :error-message="formErrors.name"
            class="q-mb-md"
            @keyup.enter="saveItem"
          />

          <div class="row q-col-gutter-sm">
            <div class="col-4">
              <q-input
                v-model.number="form.quantity"
                label="Qtd"
                outlined
                dense
                type="number"
                min="1"
              />
            </div>
            <div class="col-8">
              <q-input
                v-model="form.category"
                label="Categoria"
                outlined
                dense
                placeholder="Ex: Padaria, Hortifrúti..."
              />
            </div>
          </div>

          <q-input
            v-model="form.notes"
            label="Observações"
            outlined
            dense
            class="q-mt-md"
            type="textarea"
            rows="2"
          />
        </q-card-section>

        <q-card-actions align="right" class="dialog-actions">
          <q-btn flat label="Cancelar" color="grey-7" v-close-popup />
          <q-btn
            flat
            label="Salvar"
            color="primary"
            :loading="saving"
            @click="saveItem"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Diálogo de confirmação de exclusão -->
    <q-dialog v-model="confirmDeleteOpen" persistent>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Remover item</div>
          <q-space />
          <q-btn flat round dense icon="close" v-close-popup />
        </q-card-section>

        <q-card-section>
          <p class="q-mb-none">
            Tem certeza que deseja remover
            <strong>{{ itemToDeleteName }}</strong> da lista?
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
import { ref, nextTick, onMounted } from "vue";
import { useShoppingStore } from "src/stores/shoppingStore";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";
import ShoppingItem from "src/components/ShoppingItem.vue";

const $q = useQuasar();
const store = useShoppingStore();
const authStore = useAuthStore();

// Form state
const dialogOpen = ref(false);
const isEditing = ref(false);
const editingId = ref(null);
const saving = ref(false);
const form = ref({
  name: "",
  quantity: 1,
  category: "",
  notes: "",
});
const formErrors = ref({});
const nameInputRef = ref(null);

// Delete state
const confirmDeleteOpen = ref(false);
const deleting = ref(false);
const itemToDeleteId = ref(null);
const itemToDeleteName = ref("");

// Ícones para categorias comuns
const categoryIcons = {
  padaria: "bakery_dining",
  hortifrúti: "eco",
  hortifruti: "eco",
  frutas: "eco",
  verduras: "eco",
  legumes: "eco",
  carnes: "restaurant",
  açougue: "restaurant",
  acougue: "restaurant",
  laticínios: "egg",
  laticinios: "egg",
  leite: "egg",
  bebidas: "local_bar",
  higiene: "soap",
  limpeza: "cleaning_services",
  mercearia: "inventory_2",
  congelados: "ac_unit",
  enlatados: "camera_roll",
  temperos: "spa",
  doces: "cake",
  massas: "ramen_dining",
  molhos: "ketchup",
};

function getCategoryIcon(category) {
  const key = category.toLowerCase().trim();
  return categoryIcons[key] || "category";
}

function openAddDialog() {
  isEditing.value = false;
  editingId.value = null;
  form.value = { name: "", quantity: 1, category: "", notes: "" };
  formErrors.value = {};
  dialogOpen.value = true;
  nextTick(() => {
    nameInputRef.value?.focus();
  });
}

function openEditDialog(item) {
  isEditing.value = true;
  editingId.value = item.id;
  form.value = {
    name: item.name,
    quantity: item.quantity || 1,
    category: item.category || "",
    notes: item.notes || "",
  };
  formErrors.value = {};
  dialogOpen.value = true;
  nextTick(() => {
    nameInputRef.value?.focus();
  });
}

async function saveItem() {
  // Validação
  formErrors.value = {};
  if (!form.value.name?.trim()) {
    formErrors.value.name = "Informe o nome do item";
    return;
  }

  saving.value = true;
  try {
    if (isEditing.value) {
      const result = await store.updateItem(editingId.value, {
        name: form.value.name.trim(),
        quantity: form.value.quantity || 1,
        category: form.value.category?.trim() || null,
        notes: form.value.notes?.trim() || null,
      });
      if (!result.success) {
        $q.notify({ type: "negative", message: "Erro ao atualizar item" });
        return;
      }
    } else {
      const result = await store.createItem({
        name: form.value.name.trim(),
        quantity: form.value.quantity || 1,
        category: form.value.category?.trim() || null,
        notes: form.value.notes?.trim() || null,
      });
      if (!result.success) {
        $q.notify({
          type: "negative",
          message: result.error || "Erro ao adicionar item",
        });
        return;
      }
    }
    dialogOpen.value = false;
  } catch {
    $q.notify({ type: "negative", message: "Erro ao salvar item" });
  } finally {
    saving.value = false;
  }
}

async function handleToggle(item) {
  const result = await store.toggleItemStatus(item);
  if (!result.success) {
    $q.notify({ type: "negative", message: "Erro ao atualizar item" });
  }
}

function handleDelete(id) {
  const item = store.items.find((i) => i.id === id);
  if (!item) return;
  itemToDeleteId.value = id;
  itemToDeleteName.value = item.name;
  confirmDeleteOpen.value = true;
}

async function confirmDelete() {
  deleting.value = true;
  try {
    const result = await store.deleteItem(itemToDeleteId.value);
    if (result.success) {
      confirmDeleteOpen.value = false;
    } else {
      $q.notify({ type: "negative", message: "Erro ao remover item" });
    }
  } catch {
    $q.notify({ type: "negative", message: "Erro ao remover item" });
  } finally {
    deleting.value = false;
  }
}

// Inicialização
onMounted(async () => {
  if (authStore.couple?.id) {
    await store.initialize();
  }
});

authStore.$subscribe(async (mutation, state) => {
  if (state.couple?.id && store.items.length === 0) {
    await store.initialize();
  }
});
</script>

<style scoped lang="scss">
.shopping-page {
  padding: 0;
  background: var(--background);
  min-height: 100vh;
  padding-bottom: 80px;
}

.shopping-header {
  padding: 12px 16px 8px;
  background: var(--background);
  position: sticky;
  top: 0;
  z-index: 10;
}

.month-navigation {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.month-title {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 20px;
  transition: background 0.2s;
  user-select: none;

  &:hover {
    background: rgba(0, 0, 0, 0.04);
  }
}

.month-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary);
}

/* Progress Bar */
.progress-section {
  padding: 0 16px 16px;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.progress-label {
  font-size: 0.8125rem;
  font-weight: 500;
  color: var(--text-secondary);
}

.progress-percent {
  font-size: 0.8125rem;
  font-weight: 700;
  color: var(--positive);
}

.progress-stats {
  text-align: right;
  font-size: 0.6875rem;
  color: var(--text-muted);
  margin-top: 4px;
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

/* Items List */
.items-list {
  padding: 0 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.category-group {
  background: var(--surface);
  border: 1px solid var(--separator);
  border-radius: 14px;
  overflow: hidden;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 12px 4px;
}

.category-name {
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.category-count {
  margin-left: auto;
  font-size: 0.6875rem;
  font-weight: 500;
  color: var(--text-muted);
  background: rgba(0, 0, 0, 0.04);
  padding: 2px 8px;
  border-radius: 10px;
}

.category-items {
  padding: 0 4px 4px;
}

/* Dialog */
.item-dialog-card {
  border-radius: 20px;
  max-width: 400px;
  width: 100%;
}

.dialog-header {
  padding-bottom: 8px;
}
</style>
