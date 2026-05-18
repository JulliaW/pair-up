import { ref, onUnmounted } from "vue";
import { useAgendaStore } from "src/stores/agendaStore";
import { useAuthStore } from "src/stores/authStore";

// Chave no localStorage para controlar notificações já disparadas
const STORAGE_PREFIX = "event_notified_";

function isNotified(eventId, type) {
  return !!localStorage.getItem(`${STORAGE_PREFIX}${eventId}_${type}`);
}

function markNotified(eventId, type) {
  localStorage.setItem(`${STORAGE_PREFIX}${eventId}_${type}`, "1");
}

function showNotification(title, body) {
  // Tenta via Service Worker primeiro (funciona em background no PWA)
  if (navigator.serviceWorker?.controller) {
    navigator.serviceWorker.controller.postMessage({
      type: "SHOW_NOTIFICATION",
      payload: { title, body, tag: `event-${Date.now()}` },
    });
    return;
  }

  // Fallback: Notification API direto
  if (Notification.permission === "granted") {
    new Notification(title, {
      body,
      icon: "/favicon.ico",
      tag: `event-${Date.now()}`,
    });
  }
}

/**
 * Composable para gerenciar notificações de eventos da agenda.
 *
 * Regras:
 * - 1 dia antes: notifica AMBOS os parceiros
 * - 30 min antes (só se tiver horário): notifica APENAS o responsável
 */
export function useEventNotifications() {
  const agendaStore = useAgendaStore();
  const authStore = useAuthStore();
  let intervalId = null;

  function checkAndNotify() {
    // Só dispara se tiver permissão
    if (Notification.permission !== "granted") return;

    const now = new Date();
    const userId = authStore.user?.id;
    const events = agendaStore.events;

    if (!events || events.length === 0) return;

    for (const event of events) {
      const eventDate = new Date(event.event_date + "T23:59:59");
      const diffMs = eventDate.getTime() - now.getTime();
      const diffHours = diffMs / (1000 * 60 * 60);

      // --- NOTIFICAÇÃO 1 DIA ANTES (para ambos) ---
      if (
        diffHours >= 0 &&
        diffHours <= 24 &&
        !isNotified(event.id, "1day")
      ) {
        const timeStr = event.event_time
          ? ` às ${event.event_time.slice(0, 5)}`
          : "";
        showNotification(
          "📅 Evento amanhã!",
          `${event.title}${timeStr}`,
        );
        markNotified(event.id, "1day");
      }

      // --- NOTIFICAÇÃO 30 MIN ANTES (só responsável) ---
      if (
        event.event_time &&
        event.responsible_user_id &&
        event.responsible_user_id === userId &&
        !isNotified(event.id, "30min")
      ) {
        const eventDateTime = new Date(
          `${event.event_date}T${event.event_time}`,
        );
        const diffMin = (eventDateTime.getTime() - now.getTime()) / (1000 * 60);

        if (diffMin >= 0 && diffMin <= 30) {
          showNotification(
            "⏰ Começa em 30 minutos!",
            `${event.title} - Você é responsável!`,
          );
          markNotified(event.id, "30min");
        }
      }
    }
  }

  function startChecker() {
    // Já está rodando?
    if (intervalId) return;

    // Verifica imediatamente
    checkAndNotify();

    // Verifica a cada 60 segundos
    intervalId = setInterval(checkAndNotify, 60_000);
  }

  function stopChecker() {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
  }

  return { startChecker, stopChecker, checkAndNotify };
}