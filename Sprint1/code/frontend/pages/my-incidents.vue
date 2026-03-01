<template>
  <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">My Reported Incidents</h1>
        <p class="text-gray-600 mb-4">Track the status of incidents you've reported</p>
        <NuxtLink
          to="/report-incident"
          class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition"
        >
          Report New Incident
        </NuxtLink>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-600">Loading incidents...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="errorMessage" class="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p class="text-red-800">{{ errorMessage }}</p>
      </div>

      <!-- Empty State -->
      <div
        v-else-if="incidents.length === 0"
        class="bg-white rounded-lg shadow-md p-8 text-center"
      >
        <p class="text-gray-600 mb-4">You haven't reported any incidents yet.</p>
        <NuxtLink
          to="/report-incident"
          class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition"
        >
          Report an Incident
        </NuxtLink>
      </div>

      <!-- Incidents List -->
      <div v-else class="space-y-4">
        <div
          v-for="incident in incidents"
          :key="incident.id"
          class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition"
        >
          <div class="p-6">
            <!-- Header Row -->
            <div class="flex justify-between items-start mb-4">
              <div>
                <h3 class="text-xl font-bold text-gray-900">{{ incident.title }}</h3>
                <p class="text-sm text-gray-600 mt-1">
                  Incident Type: <span class="font-medium">{{ formatIncidentType(incident.type) }}</span>
                </p>
              </div>
              <span :class="getStatusBadgeClass(incident.status)" class="px-3 py-1 rounded-full text-sm font-medium">
                {{ formatStatus(incident.status) }}
              </span>
            </div>

            <!-- Description -->
            <p class="text-gray-700 mb-4">{{ incident.description }}</p>

            <!-- Report Against -->
            <div v-if="incident.reportedUser" class="mb-4 p-3 bg-gray-50 rounded">
              <p class="text-sm text-gray-600">
                <strong>Report Against:</strong>
                {{ incident.reportedUser.firstName }} {{ incident.reportedUser.lastName }}
                ({{ incident.reportedUser.username }})
              </p>
            </div>

            <!-- Admin Notes -->
            <div v-if="incident.adminNotes" class="mb-4 p-3 bg-blue-50 border-l-4 border-blue-400 rounded">
              <p class="text-sm text-gray-600"><strong>Admin Notes:</strong></p>
              <p class="text-sm text-gray-800 mt-1">{{ incident.adminNotes }}</p>
            </div>

            <!-- Timeline -->
            <div class="grid grid-cols-3 gap-4 text-sm text-gray-600 pt-4 border-t">
              <div>
                <p class="text-gray-500">Reported On</p>
                <p class="font-medium">{{ formatDate(incident.createdAt) }}</p>
              </div>
              <div v-if="incident.resolvedAt">
                <p class="text-gray-500">Resolved On</p>
                <p class="font-medium">{{ formatDate(incident.resolvedAt) }}</p>
              </div>
              <div v-if="incident.closedAt">
                <p class="text-gray-500">Closed On</p>
                <p class="font-medium">{{ formatDate(incident.closedAt) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="pagination && pagination.totalPages > 1" class="mt-8 flex justify-center gap-2">
        <button
          v-for="page in pagination.totalPages"
          :key="page"
          @click="currentPage = page"
          :class="currentPage === page ? 'bg-blue-600 text-white' : 'bg-white text-gray-900 border border-gray-300'"
          class="px-4 py-2 rounded-lg font-medium transition"
        >
          {{ page }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useAuth } from '~/composables/useAuth';
import { useToast } from '~/composables/useToast';

const { $api } = useNuxtApp();
const { user } = useAuth();
const toast = useToast();

const incidents = ref([]);
const loading = ref(true);
const errorMessage = ref('');
const currentPage = ref(1);
const pagination = ref(null);

const fetchIncidents = async () => {
  try {
    loading.value = true;
    errorMessage.value = '';
    const response = await $api.get(`/incidents/me?page=${currentPage.value}&limit=10`);
    incidents.value = response.data;
    pagination.value = response.pagination;
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Failed to load incidents';
    toast.addToast(errorMessage.value, 'error');
  } finally {
    loading.value = false;
  }
};

const formatIncidentType = (type) => {
  const types = {
    DRIVER_BEHAVIOR: 'Driver Behavior',
    PASSENGER_BEHAVIOR: 'Passenger Behavior',
    SAFETY_ISSUE: 'Safety Issue',
    VEHICLE_ISSUE: 'Vehicle Issue',
    HARASSMENT: 'Harassment',
    OTHER: 'Other',
  };
  return types[type] || type;
};

const formatStatus = (status) => {
  const statusMap = {
    PENDING: 'Pending Review',
    REVIEWED: 'Under Review',
    RESOLVED: 'Resolved',
    CLOSED: 'Closed',
  };
  return statusMap[status] || status;
};

const getStatusBadgeClass = (status) => {
  const classes = {
    PENDING: 'bg-yellow-100 text-yellow-800',
    REVIEWED: 'bg-blue-100 text-blue-800',
    RESOLVED: 'bg-green-100 text-green-800',
    CLOSED: 'bg-gray-100 text-gray-800',
  };
  return classes[status] || 'bg-gray-100 text-gray-800';
};

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

watch(currentPage, () => {
  fetchIncidents();
});

onMounted(() => {
  fetchIncidents();
});
</script>

<style scoped>
</style>
