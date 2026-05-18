<template>
  <q-page class="agenda-page">
    <!-- Cabeçalho do Mês -->
    <div class="month-header row items-center q-pa-md">
      <q-btn
        flat
        round
        icon="chevron_left"
        @click="agendaStore.goToPreviousMonth()"
      />
      <div class="col text-center">
        <div class="text-h6 text-weight-bold">
          {{ monthName }} {{ agendaStore.currentYear }}
        </div>
      </div>
      <q-btn
        flat
        round
        icon="chevron_right"
        @click="agendaStore.goToNextMonth()"
      />
      <q-btn
        flat
        round
        icon="today"
        @click="agendaStore.goToToday()"
        class="q-ml-sm"
      >
        <q-tooltip>Voltar para hoje</q-tooltip>
      </q-btn>
    </div>

    <!-- Dias da Semana -->
    <div class="weekdays row q-px-md">
      <div
        v-for="day in weekDays"
        :key="day"
        class="col text-center text-caption text-grey-7"
      >
        {{ day }}
      </div>
    </div>

    <!-- Grid do Calendário -->
    <div class="calendar-grid q-px-md">
      <div
        v-for="(day, index) in calendarDays"
        :key="index"
        class="calendar-day"
        :class="{
          'text-grey-4': !day.isCurrentMonth,
          'bg-primary text-white': day.isToday,
          'bg-grey-2': day.isSelected && !day.isToday,
        }"
        @click="selectDate(day)"
      >
        <span class="day-number">{{ day.day }}</span>
        <div class="day-events">
          <div
            v-for="event in day.events.slice(0, 2)"
            :key="event.id"
            class="event-dot"
            :title="event.title"
          />
          <span v-if="day.events.length > 2" class="more-events text-caption">
            +{{ day.events.length - 2 }}
          </span>
        </div>
      </div>
    </div>

    <!-- Lista de Eventos do Dia Selecionado -->
    <div class="day-events-list q-pa-md" v-if="selectedDate">
      <div class="row items-center q-mb-md">
        <div class="col">
          <div class="text-subtitle1 text-weight-bold">
            {{ formatSelectedDate }}
          </div>
        </div>
        <q-btn
          flat
          round
          icon="add"
          color="primary"
          @click="showEventDialog = true"
        >
          <q-tooltip>Novo evento</q-tooltip>
        </q-btn>
      </div>

      <div
        v-if="selectedDateEvents.length === 0"
        class="text-center text-grey-5 q-py-xl"
      >
        <q-icon name="event_busy" size="48px" />
        <p class="q-mt-sm">Nenhum evento neste dia</p>
        <q-btn
          flat
          color="primary"
          label="Adicionar evento"
          @click="showEventDialog = true"
        />
      </div>

      <div v-else class="q-gutter-sm">
        <q-card
          v-for="event in selectedDateEvents"
          :key="event.id"
          flat
          bordered
          class="event-card"
          @click="editEvent(event)"
        >
          <q-card-section class="q-pa-sm row items-center">
            <div class="col">
              <div class="text-weight-medium">{{ event.title }}</div>
              <div class="text-caption text-grey-7" v-if="event.event_time">
                {{ event.event_time.slice(0, 5) }}
              </div>
              <div class="text-caption text-grey-7" v-if="event.description">
                {{ event.description }}
              </div>
            </div>
            <q-btn
              flat
              round
              dense
              icon="close"
              size="sm"
              @click.stop="handleDeleteEvent(event.id)"
            />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- FAB para adicionar evento -->
    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <q-btn fab icon="add" color="primary" @click="showEventDialog = true" />
    </q-page-sticky>

    <!-- Dialog de Evento (Criar/Editar) -->
    <q-dialog v-model="showEventDialog" maximized>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">
            {{ editingEvent ? "Editar" : "Novo" }} Evento
          </div>
          <q-space />
          <q-btn flat round dense icon="close" v-close-popup />
        </q-card-section>

        <q-card-section>
          <q-form @submit.prevent="handleSaveEvent" class="q-gutter-md">
            <q-input
              v-model="eventForm.title"
              label="Título"
              outlined
              dense
              :rules="[(val) => !!val || 'Título é obrigatório']"
              autofocus
            />

            <q-input
              v-model="eventForm.description"
              label="Descrição"
              outlined
              dense
              type="textarea"
              rows="3"
            />

            <q-input
              v-model="eventForm.event_date"
              label="Data"
              type="date"
              outlined
              dense
              :rules="[(val) => !!val || 'Data é obrigatória']"
            />

            <q-input
              v-model="eventForm.event_time"
              label="Horário (opcional)"
              type="time"
              outlined
              dense
            />

            <q-select
              v-model="eventForm.recurrence"
              label="Recorrência"
              :options="recurrenceOptions"
              outlined
              dense
              emit-value
              map-options
            />

            <q-select
              v-model="eventForm.responsible_user_id"
              label="Responsável (opcional)"
              :options="partnerOptions"
              outlined
              dense
              emit-value
              map-options
              clearable
            />

            <div class="row q-gutter-sm">
              <q-btn
                v-if="editingEvent"
                flat
                color="negative"
                label="Excluir"
                @click="handleDeleteEvent(editingEvent.id)"
              />
              <q-space />
              <q-btn flat label="Cancelar" color="negative" v-close-popup />
              <q-btn type="submit" label="Salvar" color="primary" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, watch, onMounted } from "vue";
import { useAgendaStore } from "src/stores/agendaStore";
import { useAuthStore } from "src/stores/authStore";
import { useQuasar } from "quasar";
import { getMonthName } from "src/utils/formatters";

const $q = useQuasar();
const agendaStore = useAgendaStore();
const authStore = useAuthStore();

const showEventDialog = ref(false);
const editingEvent = ref(null);
const selectedDate = ref(null);

const weekDays = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];

const recurrenceOptions = [
  { label: "Não repete", value: "none" },
  { label: "Diariamente", value: "daily" },
  { label: "Semanalmente", value: "weekly" },
  { label: "Mensalmente", value: "monthly" },
  { label: "Anualmente", value: "yearly" },
];

const partnerOptions = computed(() => {
  const options = [];
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
      options.push({ label: me.name || "Você", value: me.id });
    }
  }
  return options;
});

const eventForm = ref({
  title: "",
  description: "",
  event_date: "",
  event_time: "",
  recurrence: "none",
  responsible_user_id: null,
});

const monthName = computed(() => {
  return getMonthName(agendaStore.currentMonth);
});

const calendarDays = computed(() => {
  const days = [];
  const firstDay = new Date(
    agendaStore.currentYear,
    agendaStore.currentMonth,
    1,
  );
  const lastDay = new Date(
    agendaStore.currentYear,
    agendaStore.currentMonth + 1,
    0,
  );
  const startPad = firstDay.getDay();
  const totalDays = lastDay.getDate();

  // Dias do mês anterior
  const prevLastDay = new Date(
    agendaStore.currentYear,
    agendaStore.currentMonth,
    0,
  );
  for (let i = startPad - 1; i >= 0; i--) {
    const day = prevLastDay.getDate() - i;
    days.push(
      createDayObject(
        day,
        false,
        prevLastDay.getMonth(),
        prevLastDay.getFullYear(),
      ),
    );
  }

  // Dias do mês atual
  for (let i = 1; i <= totalDays; i++) {
    days.push(
      createDayObject(
        i,
        true,
        agendaStore.currentMonth,
        agendaStore.currentYear,
      ),
    );
  }

  // Dias do próximo mês
  const remaining = 42 - days.length; // 6 linhas completas
  for (let i = 1; i <= remaining; i++) {
    const nextMonth =
      agendaStore.currentMonth === 11 ? 0 : agendaStore.currentMonth + 1;
    const nextYear =
      agendaStore.currentMonth === 11
        ? agendaStore.currentYear + 1
        : agendaStore.currentYear;
    days.push(createDayObject(i, false, nextMonth, nextYear));
  }

  return days;
});

function createDayObject(day, isCurrentMonth, month, year) {
  const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
  const today = new Date();
  const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, "0")}-${String(today.getDate()).padStart(2, "0")}`;

  return {
    day,
    date: dateStr,
    isCurrentMonth,
    isToday: dateStr === todayStr,
    isSelected: selectedDate.value === dateStr,
    month,
    year,
    events: agendaStore.events.filter((e) => e.event_date === dateStr),
  };
}

const formatSelectedDate = computed(() => {
  if (!selectedDate.value) return "";
  const d = new Date(selectedDate.value + "T12:00:00");
  const weekDay = weekDays[d.getDay()];
  const day = String(d.getDate()).padStart(2, "0");
  const month = getMonthName(d.getMonth(), true);
  return `${weekDay}, ${day} de ${month}`;
});

const selectedDateEvents = computed(() => {
  if (!selectedDate.value) return [];
  return agendaStore.events.filter((e) => e.event_date === selectedDate.value);
});

function selectDate(day) {
  selectedDate.value = day.date;
  resetForm();
  editingEvent.value = null;
}

function editEvent(event) {
  editingEvent.value = event;
  eventForm.value = {
    title: event.title,
    description: event.description || "",
    event_date: event.event_date,
    event_time: event.event_time || "",
    recurrence: event.recurrence || "none",
    responsible_user_id: event.responsible_user_id,
  };
  showEventDialog.value = true;
}

function resetForm() {
  eventForm.value = {
    title: "",
    description: "",
    event_date: selectedDate.value || "",
    event_time: "",
    recurrence: "none",
    responsible_user_id: null,
  };
}

async function handleSaveEvent() {
  let result;
  if (editingEvent.value) {
    result = await agendaStore.updateEvent(
      editingEvent.value.id,
      eventForm.value,
    );
  } else {
    result = await agendaStore.createEvent(eventForm.value);
  }

  if (result.success) {
    showEventDialog.value = false;
    resetForm();
    $q.notify({ type: "positive", message: "Evento salvo!", position: "top" });
  } else {
    $q.notify({
      type: "negative",
      message: result.error || "Erro ao salvar evento",
      position: "top",
    });
  }
}

async function handleDeleteEvent(id) {
  const result = await agendaStore.deleteEvent(id);
  if (result.success) {
    showEventDialog.value = false;
    editingEvent.value = null;
    $q.notify({
      type: "positive",
      message: "Evento excluído!",
      position: "top",
    });
  }
}

watch(showEventDialog, (val) => {
  if (!val) {
    editingEvent.value = null;
  } else if (!editingEvent.value) {
    resetForm();
  }
});

onMounted(() => {
  agendaStore.fetchEvents();
  selectedDate.value = new Date().toISOString().split("T")[0];
});
</script>

<style scoped lang="scss">
.agenda-page {
  max-width: 600px;
  margin: 0 auto;
}

.month-header {
  position: sticky;
  top: 0;
  background: inherit;
  z-index: 1;
}

.weekdays {
  padding-bottom: 4px;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
}

.calendar-day {
  aspect-ratio: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  min-height: 48px;
  transition: background-color 0.2s;

  &:hover {
    background: rgba(0, 0, 0, 0.05);
  }
}

.day-number {
  font-size: 14px;
  font-weight: 500;
}

.day-events {
  display: flex;
  gap: 2px;
  align-items: center;
  margin-top: 2px;
}

.event-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: $primary;
}

.more-events {
  font-size: 10px;
  color: $grey-7;
  margin-left: 2px;
}

.event-card {
  border-radius: 8px;
  cursor: pointer;
  transition: box-shadow 0.2s;

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
}
</style>
