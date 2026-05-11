<template>
  <q-layout view="lhh lpR fff" class="main-layout">
    <!-- Header -->
    <q-header v-if="showHeader" elevated class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title class="text-weight-medium">
          {{ pageTitle }}
        </q-toolbar-title>

        <q-btn
          flat
          round
          dense
          :icon="isDark ? 'light_mode' : 'dark_mode'"
          @click="toggleDarkMode"
        >
          <q-tooltip>Alternar tema</q-tooltip>
        </q-btn>

        <q-btn flat round dense icon="account_circle">
          <q-menu auto-close>
            <q-list style="min-width: 180px">
              <q-item clickable @click="handleLogout">
                <q-item-section avatar>
                  <q-icon name="logout" />
                </q-item-section>
                <q-item-section>Sair</q-item-section>
              </q-item>
            </q-list>
          </q-menu>
        </q-btn>
      </q-toolbar>
    </q-header>

    <!-- Conteúdo Principal -->
    <q-page-container>
      <router-view />
    </q-page-container>

    <!-- Bottom Navigation -->
    <q-footer v-if="showBottomNav" bordered class="bg-white text-grey-8">
      <q-tabs
        v-model="currentTab"
        dense
        active-color="primary"
        indicator-color="transparent"
        class="bottom-nav"
        @update:model-value="navigateTo"
      >
        <q-tab
          v-for="tab in bottomTabs"
          :key="tab.route"
          :name="tab.route"
          :icon="tab.icon"
          :label="tab.label"
          :class="{ 'q-tab--active': currentTab === tab.route }"
        />
      </q-tabs>
    </q-footer>
  </q-layout>
</template>

<script setup>
import { ref, computed, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";

const $q = useQuasar();
const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const isDark = ref($q.dark.isActive);

const bottomTabs = [
  { icon: "home", label: "Início", route: "/" },
  { icon: "calendar_month", label: "Agenda", route: "/agenda" },
  { icon: "shopping_cart", label: "Compras", route: "/compras" },
  { icon: "checklist", label: "Tarefas", route: "/tarefas" },
  { icon: "account_balance", label: "Finanças", route: "/financas" },
];

// Mapeamento de rotas para títulos
const routeTitles = {
  "/": "Dashboard",
  "/agenda": "Agenda",
  "/compras": "Lista de Compras",
  "/tarefas": "Tarefas",
  "/metas": "Metas",
  "/financas": "Finanças",
  "/financas/transacoes": "Transações",
  "/financas/cartoes": "Cartões de Crédito",
  "/financas/apartamento": "Apartamento",
  "/financas/cofrinho": "Cofrinho",
};

// Rotas que não exibem o header
const routesWithoutHeader = ["/login"];
// Rotas que não exibem a bottom nav
const routesWithoutBottomNav = ["/login"];

const currentTab = ref("/");

// Sincroniza a tab ativa com a rota atual
watch(
  () => route.path,
  (path) => {
    if (path === "/") {
      currentTab.value = "/";
    } else if (path.startsWith("/agenda")) {
      currentTab.value = "/agenda";
    } else if (path.startsWith("/compras")) {
      currentTab.value = "/compras";
    } else if (path.startsWith("/tarefas")) {
      currentTab.value = "/tarefas";
    } else if (path.startsWith("/financas") || path.startsWith("/metas")) {
      currentTab.value = "/financas";
    }
  },
  { immediate: true },
);

const pageTitle = computed(() => {
  return routeTitles[route.path] || "PairUp";
});

const showHeader = computed(() => {
  return !routesWithoutHeader.includes(route.path);
});

const showBottomNav = computed(() => {
  return !routesWithoutBottomNav.includes(route.path);
});

function navigateTo(routeName) {
  router.push(routeName);
}

function toggleDarkMode() {
  isDark.value = !isDark.value;
  $q.dark.set(isDark.value);
}

async function handleLogout() {
  await authStore.logout();
  router.push("/login");
}
</script>

<style scoped lang="scss">
.main-layout {
  // Garante que o conteúdo não fique atrás da bottom nav
  .q-page-container {
    padding-bottom: 56px; // altura da bottom nav
  }
}

.bottom-nav {
  height: 56px;

  .q-tab {
    min-width: auto;
    padding: 4px 8px;

    &--active {
      .q-tab__icon {
        font-variation-settings: "FILL" 1;
      }
    }
  }
}

// Ajuste para quando não tem header
body:not(.has-header) {
  .q-page-container {
    padding-top: 0;
  }
}
</style>
