<template>
  <q-layout>
    <q-page-container>
      <q-page class="login-page flex flex-center bg-grey-1">
        <div class="login-container">
          <!-- Logo / Título -->
          <div class="text-center q-mb-xl">
            <q-icon name="favorite" color="primary" size="64px" />
            <h4 class="q-mt-sm q-mb-xs text-weight-bold">PairUp</h4>
            <p class="text-grey-7 q-mt-none">Organize a vida a dois</p>
          </div>

          <!-- Formulário -->
          <q-card flat bordered class="login-card">
            <q-card-section>
              <q-tabs
                v-model="tab"
                dense
                class="text-grey"
                active-color="primary"
                indicator-color="primary"
                align="justify"
              >
                <q-tab name="login" label="Entrar" />
                <q-tab name="register" label="Cadastrar" />
              </q-tabs>

              <q-separator />

              <q-tab-panels v-model="tab" animated>
                <!-- Painel de Login -->
                <q-tab-panel name="login" class="q-px-none">
                  <q-form @submit.prevent="handleLogin" class="q-gutter-md">
                    <q-input
                      v-model="email"
                      label="Email"
                      type="email"
                      outlined
                      dense
                      :rules="[(val) => !!val || 'Email é obrigatório']"
                    >
                      <template v-slot:prepend>
                        <q-icon name="email" />
                      </template>
                    </q-input>

                    <q-input
                      v-model="password"
                      label="Senha"
                      :type="showPassword ? 'text' : 'password'"
                      outlined
                      dense
                      :rules="[
                        (val) => !!val || 'Senha é obrigatória',
                        (val) => val.length >= 6 || 'Mínimo 6 caracteres',
                      ]"
                    >
                      <template v-slot:prepend>
                        <q-icon name="lock" />
                      </template>
                      <template v-slot:append>
                        <q-icon
                          :name="showPassword ? 'visibility_off' : 'visibility'"
                          class="cursor-pointer"
                          @click="showPassword = !showPassword"
                        />
                      </template>
                    </q-input>

                    <q-btn
                      type="submit"
                      label="Entrar"
                      color="primary"
                      class="full-width"
                      :loading="authStore.loading"
                      :disable="authStore.loading"
                    />
                  </q-form>
                </q-tab-panel>

                <!-- Painel de Cadastro -->
                <q-tab-panel name="register" class="q-px-none">
                  <!-- Pergunta se tem convite antes do formulário -->
                  <div v-if="showInviteQuestion" class="text-center q-mb-md">
                    <p class="text-grey-7">
                      Você já tem um código de convite do seu parceiro(a)?
                    </p>
                    <div class="row q-gutter-sm q-mt-md justify-center">
                      <q-btn
                        outline
                        color="primary"
                        label="Sim, tenho um código"
                        @click="
                          showInviteQuestion = false;
                          hasInviteCode = true;
                        "
                      />
                      <q-btn
                        outline
                        color="grey"
                        label="Não, quero criar um casal"
                        @click="
                          showInviteQuestion = false;
                          hasInviteCode = false;
                        "
                      />
                    </div>
                  </div>

                  <!-- Formulário de cadastro -->
                  <div v-else>
                    <q-form
                      @submit.prevent="handleRegister"
                      class="q-gutter-md"
                    >
                      <q-btn
                        flat
                        dense
                        icon="arrow_back"
                        label="Voltar"
                        class="q-mb-sm"
                        @click="
                          showInviteQuestion = true;
                          hasInviteCode = null;
                        "
                      />

                      <q-input
                        v-model="name"
                        label="Seu nome"
                        outlined
                        dense
                        :rules="[(val) => !!val || 'Nome é obrigatório']"
                      >
                        <template v-slot:prepend>
                          <q-icon name="person" />
                        </template>
                      </q-input>

                      <q-input
                        v-model="email"
                        label="Email"
                        type="email"
                        outlined
                        dense
                        :rules="[(val) => !!val || 'Email é obrigatório']"
                      >
                        <template v-slot:prepend>
                          <q-icon name="email" />
                        </template>
                      </q-input>

                      <q-input
                        v-model="password"
                        label="Senha"
                        :type="showPassword ? 'text' : 'password'"
                        outlined
                        dense
                        :rules="[
                          (val) => !!val || 'Senha é obrigatória',
                          (val) => val.length >= 6 || 'Mínimo 6 caracteres',
                        ]"
                      >
                        <template v-slot:prepend>
                          <q-icon name="lock" />
                        </template>
                        <template v-slot:append>
                          <q-icon
                            :name="
                              showPassword ? 'visibility_off' : 'visibility'
                            "
                            class="cursor-pointer"
                            @click="showPassword = !showPassword"
                          />
                        </template>
                      </q-input>

                      <q-input
                        v-model="confirmPassword"
                        label="Confirmar senha"
                        :type="showPassword ? 'text' : 'password'"
                        outlined
                        dense
                        :rules="[
                          (val) => !!val || 'Confirme sua senha',
                          (val) => val === password || 'Senhas não conferem',
                        ]"
                      >
                        <template v-slot:prepend>
                          <q-icon name="lock" />
                        </template>
                      </q-input>

                      <q-btn
                        type="submit"
                        :label="
                          hasInviteCode
                            ? 'Criar conta e aceitar convite'
                            : 'Criar conta'
                        "
                        color="primary"
                        class="full-width"
                        :loading="authStore.loading"
                        :disable="authStore.loading"
                      />
                    </q-form>
                  </div>
                </q-tab-panel>
              </q-tab-panels>
            </q-card-section>

            <!-- Mensagem de sucesso no cadastro (Usuário 1 - criou casal) -->
            <q-card-section
              v-if="registrationSuccess && !needsInvite"
              class="bg-positive text-white"
            >
              <div class="text-center">
                <q-icon name="check_circle" size="32px" />
                <p class="q-mt-sm q-mb-xs text-weight-bold">
                  Conta criada com sucesso!
                </p>
                <p class="q-mb-xs">
                  Compartilhe o código abaixo com seu parceiro(a):
                </p>
                <div class="invite-code-display text-center q-my-md">
                  <span class="text-h4 text-weight-bold">{{ inviteCode }}</span>
                </div>
                <q-btn
                  flat
                  color="white"
                  icon="content_copy"
                  label="Copiar código"
                  @click="copyInviteCode"
                  class="q-mt-sm"
                />
                <p class="text-caption q-mt-sm">
                  Seu parceiro(a) deve clicar em "Cadastrar", depois em "Sim,
                  tenho um código"
                </p>
              </div>
            </q-card-section>

            <!-- Mensagem de sucesso no cadastro (Usuário 2 - vai aceitar convite) -->
            <q-card-section
              v-if="registrationSuccess && needsInvite"
              class="bg-primary text-white"
            >
              <div class="text-center">
                <q-icon name="vpn_key" size="32px" />
                <p class="q-mt-sm q-mb-xs text-weight-bold">
                  Conta criada! Agora vincule ao seu parceiro(a)
                </p>
                <p class="q-mb-xs">
                  Você será redirecionado para inserir o código de convite.
                </p>
              </div>
            </q-card-section>
          </q-card>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";

const $q = useQuasar();
const router = useRouter();
const authStore = useAuthStore();

const tab = ref("login");
const email = ref("");
const password = ref("");
const confirmPassword = ref("");
const name = ref("");
const showPassword = ref(false);
const hasInviteCode = ref(null);
const showInviteQuestion = ref(true);

const registrationSuccess = ref(false);
const inviteCode = ref("");
const needsInvite = ref(false);

async function handleLogin() {
  const result = await authStore.login(email.value, password.value);
  if (result.success) {
    router.push("/");
  } else {
    $q.notify({
      type: "negative",
      message: result.error || "Erro ao fazer login",
      position: "top",
    });
  }
}

async function handleRegister() {
  if (password.value !== confirmPassword.value) {
    $q.notify({
      type: "warning",
      message: "Senhas não conferem",
      position: "top",
    });
    return;
  }

  const result = await authStore.register(
    email.value,
    password.value,
    name.value,
    hasInviteCode.value,
  );

  if (result.success) {
    registrationSuccess.value = true;

    if (hasInviteCode.value) {
      // Usuário 2 - tem convite, redireciona para aceitar
      needsInvite.value = true;
      setTimeout(() => {
        router.push("/aceitar-convite");
      }, 1500);
    } else {
      // Usuário 1 - criou casal, mostra o código
      inviteCode.value = result.inviteCode;
      $q.notify({
        type: "positive",
        message: "Conta criada! Compartilhe o código com seu parceiro(a).",
        position: "top",
      });
    }
  } else {
    $q.notify({
      type: "negative",
      message: result.error || "Erro ao criar conta",
      position: "top",
    });
  }
}

async function copyInviteCode() {
  try {
    await navigator.clipboard.writeText(inviteCode.value);
    $q.notify({
      type: "positive",
      message: "Código copiado!",
      position: "top",
    });
  } catch {
    $q.notify({
      type: "negative",
      message: "Erro ao copiar. Selecione manualmente.",
      position: "top",
    });
  }
}
</script>

<style scoped lang="scss">
.login-page {
  min-height: 100vh;
}

.login-container {
  width: 100%;
  max-width: 420px;
  padding: 16px;
}

.login-card {
  border-radius: 12px;
}

.invite-code-display {
  background: rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  padding: 8px 16px;
  letter-spacing: 8px;
}
</style>
