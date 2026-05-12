<template>
  <div class="dashboard-header">
    <div class="header-content">
      <div class="greeting">
        <p class="greeting-label">{{ greeting }}</p>
        <h2 class="greeting-name">{{ displayName }}</h2>
      </div>
      <q-btn flat round class="profile-btn" @click="$router.push('/convidar')">
        <q-icon name="person" size="20px" />
      </q-btn>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { useAuthStore } from "src/stores/authStore";

const authStore = useAuthStore();

const greeting = computed(() => {
  const hour = new Date().getHours();
  if (hour < 12) return "Bom dia,";
  if (hour < 18) return "Boa tarde,";
  return "Boa noite,";
});

const displayName = computed(() => {
  return authStore.user?.name || "Casal";
});
</script>

<style scoped lang="scss">
.dashboard-header {
  padding: 8px 16px 4px;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.greeting {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.greeting-label {
  font-size: 0.875rem;
  color: var(--text-secondary);
  margin: 0;
  line-height: 1.2;
}

.greeting-name {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  line-height: 1.3;
}

.profile-btn {
  background: rgba(var(--q-primary-rgb), 0.1);
  color: var(--q-primary);
}
</style>
