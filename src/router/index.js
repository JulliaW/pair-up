import { defineRouter } from '#q-app/wrappers'
import { createRouter, createMemoryHistory, createWebHistory, createWebHashHistory } from 'vue-router'
import routes from './routes'
import { useAuthStore } from 'src/stores/authStore'

/*
 * If not building with SSR mode, you can
 * directly export the Router instantiation;
 *
 * The function below can be async too; either use
 * async/await or return a Promise which resolves
 * with the Router instance.
 */

export default defineRouter((/* { store, ssrContext } */) => {
  const createHistory = process.env.SERVER
    ? createMemoryHistory
    : (process.env.VUE_ROUTER_MODE === 'history' ? createWebHistory : createWebHashHistory)

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,

    // Leave this as is and make changes in quasar.conf.js instead!
    // quasar.conf.js -> build -> vueRouterMode
    // quasar.conf.js -> build -> publicPath
    history: createHistory(process.env.VUE_ROUTER_BASE)
  })

  // Guard de autenticação global
  // Nota: Vue Router 5 não usa mais callback next()
  Router.beforeEach(async (to) => {
    const authStore = useAuthStore()

    // Aguarda a inicialização se ainda estiver carregando
    if (authStore.initializing) {
      await new Promise((resolve) => {
        const unwatch = authStore.$subscribe((mutation, state) => {
          if (!state.initializing) {
            unwatch()
            resolve()
          }
        })
      })
    }

    const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

    if (requiresAuth && !authStore.isAuthenticated) {
      // Redireciona para login se não estiver autenticado
      return { name: 'login' }
    } else if (to.name === 'login' && authStore.isAuthenticated) {
      // Redireciona para dashboard se já estiver autenticado
      return { name: 'dashboard' }
    }

    // Retorna true para permitir navegação
    return true
  })

  return Router
})