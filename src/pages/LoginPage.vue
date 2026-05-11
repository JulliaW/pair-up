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
                  <q-form @submit.prevent="handleRegister" class="q-gutter-md">
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
                          :name="showPassword ? 'visibility_off' : 'visibility'"
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
                      label="Criar conta"
                      color="primary"
                      class="full-width"
                      :loading="authStore.loading"
                      :disable="authStore.loading"
                    />
                  </q-form>
                </q-tab-panel>
              </q-tab-panels>
            </q-card-section>

            <!-- Seção de Convite -->
            <q-card-section v-if="tab === 'login'" class="q-pt-none">
              <q-separator class="q-mb-md" />
              <p class="text-caption text-center text-grey-7">
                Já tem um código de convite?
              </p>
              <q-btn
                flat
                color="secondary"
                class="full-width"
                label="Aceitar Convite"
                @click="showInviteDialog = true"
              />
            </q-card-section>

            <!-- Mensagem de sucesso no cadastro -->
            <q-card-section
              v-if="registrationSuccess"
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
                <p class="text-caption">
                  Seu parceiro deve usar este código na opção "Aceitar Convite"
                </p>
              </div>
            </q-card-section>
          </q-card>

          <!-- Dialog para aceitar convite -->
          <q-dialog v-model="showInviteDialog">
            <q-card style="min-width: 300px">
              <q-card-section>
                <div class="text-h6">Aceitar Convite</div>
              </q-card-section>

              <q-card-section>
                <q-input
                  v-model="inviteCodeInput"
                  label="Código do convite"
                  outlined
                  dense
                  autofocus
                  hint="Insira o código de 6 caracteres que seu parceiro(a) compartilhou"
                  maxlength="6"
                  class="text-center"
                >
                  <template v-slot:prepend>
                    <q-icon name="vpn_key" />
                  </template>
                </q-input>
              </q-card-section>

              <q-card-actions align="right">
                <q-btn flat label="Cancelar" color="negative" v-close-popup />
                <q-btn
                  flat
                  label="Aceitar"
                  color="primary"
                  :loading="authStore.loading"
                  @click="handleAcceptInvite"
                />
              </q-card-actions>
            </q-card>
          </q-dialog>
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

const showInviteDialog = ref(false);
const inviteCodeInput = ref("");

const registrationSuccess = ref(false);
const inviteCode = ref("");

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
  );
  if (result.success) {
    registrationSuccess.value = true;
    inviteCode.value = result.inviteCode;
    $q.notify({
      type: "positive",
      message: "Conta criada com sucesso!",
      position: "top",
    });
  } else {
    $q.notify({
      type: "negative",
      message: result.error || "Erro ao criar conta",
      position: "top",
    });
  }
}

async function handleAcceptInvite() {
  if (!inviteCodeInput.value || inviteCodeInput.value.length !== 6) {
    $q.notify({
      type: "warning",
      message: "Insira um código de convite válido (6 caracteres)",
      position: "top",
    });
    return;
  }

  const result = await authStore.acceptInvite(
    inviteCodeInput.value.toUpperCase(),
  );
  if (result.success) {
    showInviteDialog.value = false;
    $q.notify({
      type: "positive",
      message: "Agora você faz parte do casal!",
      position: "top",
    });
    router.push("/");
  } else {
    $q.notify({
      type: "negative",
      message: result.error || "Erro ao aceitar convite",
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
