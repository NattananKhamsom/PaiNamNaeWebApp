<template>
  <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-6xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Incident Management</h1>
        
        <!-- Filters -->
        <div class="bg-white rounded-lg shadow p-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              v-model="filters.status"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Statuses</option>
              <option value="PENDING">Pending Review</option>
              <option value="REVIEWED">Under Review</option>
              <option value="RESOLVED">Resolved</option>
              <option value="CLOSED">Closed</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Type</label>
            <select
              v-model="filters.type"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Types</option>
              <option value="DRIVER_BEHAVIOR">Driver Behavior</option>
              <option value="PASSENGER_BEHAVIOR">Passenger Behavior</option>
              <option value="SAFETY_ISSUE">Safety Issue</option>
              <option value="VEHICLE_ISSUE">Vehicle Issue</option>
              <option value="HARASSMENT">Harassment</option>
              <option value="OTHER">Other</option>
            </select>
          </div>

          <div class="flex items-end">
            <button
              @click="applyFilters"
              class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition"
            >
              Apply Filters
            </button>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-600">Loading incidents...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="errorMessage" class="p-4 bg-red-50 border border-red-200 rounded-lg mb-4">
        <p class="text-red-800">{{ errorMessage }}</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="incidents.length === 0" class="bg-white rounded-lg shadow-md p-8 text-center">
        <p class="text-gray-600">No incidents found.</p>
      </div>

      <!-- Incidents Table -->
      <div v-else class="bg-white rounded-lg shadow-md overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-100 border-b">
            <tr>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Title</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Type</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Reporter</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Status</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Date</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y">
            <tr v-for="incident in incidents" :key="incident.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 text-sm text-gray-900 font-medium">{{ incident.title }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ formatIncidentType(incident.type) }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ incident.reporter.username }}</td>
              <td class="px-6 py-4">
                <span :class="getStatusBadgeClass(incident.status)" class="px-3 py-1 rounded-full text-xs font-medium">
                  {{ formatStatus(incident.status) }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ formatDate(incident.createdAt) }}</td>
              <td class="px-6 py-4">
                <button
                  @click="selectIncident(incident)"
                  class="text-blue-600 hover:text-blue-800 font-medium text-sm"
                >
                  View Details
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="pagination && pagination.totalPages > 1" class="mt-8 flex justify-center gap-2">
        <button
          v-for="page in pagination.totalPages"
          :key="page"
          @click="currentPage = page; applyFilters()"
          :class="currentPage === page ? 'bg-blue-600 text-white' : 'bg-white text-gray-900 border border-gray-300'"
          class="px-4 py-2 rounded-lg font-medium transition"
        >
          {{ page }}
        </button>
      </div>
    </div>

    <!-- Detail Modal -->
    <div
      v-if="selectedIncident"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    >
      <div class="bg-white rounded-lg shadow-lg max-w-2xl w-full max-h-96 overflow-y-auto">
        <div class="p-6">
          <!-- Header -->
          <div class="flex justify-between items-start mb-4">
            <div>
              <h2 class="text-2xl font-bold text-gray-900">{{ selectedIncident.title }}</h2>
              <p class="text-sm text-gray-600 mt-1">
                Type: <span class="font-medium">{{ formatIncidentType(selectedIncident.type) }}</span>
              </p>
            </div>
            <span
              :class="getStatusBadgeClass(selectedIncident.status)"
              class="px-3 py-1 rounded-full text-sm font-medium"
            >
              {{ formatStatus(selectedIncident.status) }}
            </span>
          </div>

          <!-- Description -->
          <div class="mb-4">
            <h3 class="font-semibold text-gray-900 mb-2">Description:</h3>
            <p class="text-gray-700">{{ selectedIncident.description }}</p>
          </div>

          <!-- Reporter & Reported User -->
          <div class="grid grid-cols-2 gap-4 mb-4 p-3 bg-gray-50 rounded">
            <div>
              <p class="text-sm text-gray-600"><strong>Reporter:</strong></p>
              <p class="text-sm text-gray-800">
                {{ selectedIncident.reporter.firstName }} {{ selectedIncident.reporter.lastName }}
                <br />
                <span class="text-xs">({{ selectedIncident.reporter.username }})</span>
              </p>
            </div>
            <div v-if="selectedIncident.reportedUser">
              <p class="text-sm text-gray-600"><strong>Against:</strong></p>
              <p class="text-sm text-gray-800">
                {{ selectedIncident.reportedUser.firstName }} {{ selectedIncident.reportedUser.lastName }}
                <br />
                <span class="text-xs">({{ selectedIncident.reportedUser.username }})</span>
              </p>
            </div>
          </div>

          <!-- Update Status Form -->
          <div class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded">
            <h3 class="font-semibold text-gray-900 mb-3">Update Status:</h3>
            <div class="space-y-3">
              <select
                v-model="updateForm.status"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="PENDING">Pending Review</option>
                <option value="REVIEWED">Under Review</option>
                <option value="RESOLVED">Resolved</option>
                <option value="CLOSED">Closed</option>
              </select>

              <textarea
                v-model="updateForm.adminNotes"
                placeholder="Add admin notes (optional)"
                rows="3"
                maxlength="1000"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              ></textarea>

              <button
                @click="updateStatus"
                :disabled="updatingStatus"
                class="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-medium py-2 px-4 rounded-lg transition"
              >
                {{ updatingStatus ? 'Updating...' : 'Update Status' }}
              </button>
            </div>
          </div>

          <!-- Admin Notes Display -->
          <div v-if="selectedIncident.adminNotes" class="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded">
            <p class="text-sm text-gray-600"><strong>Admin Notes:</strong></p>
            <p class="text-sm text-gray-800 mt-1">{{ selectedIncident.adminNotes }}</p>
          </div>

          <!-- Close Button -->
          <button
            @click="selectedIncident = null"
            class="w-full bg-gray-300 hover:bg-gray-400 text-gray-900 font-medium py-2 px-4 rounded-lg transition"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useAuth } from '~/composables/useAuth';
import { useToast } from '~/composables/useToast';

const { $api } = useNuxtApp();
const router = useRouter();
const { user } = useAuth();
const toast = useToast();

// Check if user is admin
if (user.value?.role !== 'ADMIN') {
  router.push('/');
}

const incidents = ref([]);
const loading = ref(true);
const errorMessage = ref('');
const currentPage = ref(1);
const pagination = ref(null);
const selectedIncident = ref(null);
const updatingStatus = ref(false);

const filters = ref({
  status: '',
  type: '',
});

const updateForm = ref({
  status: 'PENDING',
  adminNotes: '',
});

const fetchIncidents = async () => {
  try {
    loading.value = true;
    errorMessage.value = '';

    let url = `/incidents/admin/all?page=${currentPage.value}&limit=10`;
    if (filters.value.status) {
      url += `&status=${filters.value.status}`;
    }
    if (filters.value.type) {
      url += `&type=${filters.value.type}`;
    }

    const response = await $api.get(url);
    incidents.value = response.data;
    pagination.value = response.pagination;
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Failed to load incidents';
    toast.addToast(errorMessage.value, 'error');
  } finally {
    loading.value = false;
  }
};

const applyFilters = () => {
  currentPage.value = 1;
  fetchIncidents();
};

const selectIncident = (incident) => {
  selectedIncident.value = incident;
  updateForm.value = {
    status: incident.status,
    adminNotes: incident.adminNotes || '',
  };
};

const updateStatus = async () => {
  try {
    updatingStatus.value = true;
    await $api.patch(`/incidents/admin/${selectedIncident.value.id}/status`, {
      status: updateForm.value.status,
      adminNotes: updateForm.value.adminNotes,
    });

    toast.addToast('Incident status updated successfully', 'success');
    selectedIncident.value = null;
    fetchIncidents();
  } catch (error) {
    toast.addToast(error.response?.data?.message || 'Failed to update incident', 'error');
  } finally {
    updatingStatus.value = false;
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

onMounted(() => {
  fetchIncidents();
});
</script>

<style scoped>
</style>
