<template>
  <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-2xl mx-auto">
      <div class="bg-white rounded-lg shadow-md p-6 md:p-8">
        <!-- Header -->
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">Report Incident</h1>
          <p class="text-gray-600">Help us maintain a safe community by reporting incidents</p>
        </div>

        <!-- Alert Message -->
        <div v-if="successMessage" class="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg">
          <p class="text-green-800">{{ successMessage }}</p>
        </div>

        <div v-if="errorMessage" class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-red-800">{{ errorMessage }}</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="submitReport" class="space-y-6">
          <!-- Incident Type -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Incident Type <span class="text-red-500">*</span>
            </label>
            <select
              v-model="form.type"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">-- Select incident type --</option>
              <option value="DRIVER_BEHAVIOR">Driver Behavior Issue</option>
              <option value="PASSENGER_BEHAVIOR">Passenger Behavior Issue</option>
              <option value="SAFETY_ISSUE">Safety Issue</option>
              <option value="VEHICLE_ISSUE">Vehicle Issue</option>
              <option value="HARASSMENT">Harassment</option>
              <option value="OTHER">Other</option>
            </select>
          </div>

          <!-- Title -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Title <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.title"
              type="text"
              placeholder="Brief title of the incident"
              required
              maxlength="100"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p class="text-xs text-gray-500 mt-1">{{ form.title.length }}/100 characters</p>
          </div>

          <!-- Description -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Description <span class="text-red-500">*</span>
            </label>
            <textarea
              v-model="form.description"
              placeholder="Detailed description of the incident (minimum 10 characters)"
              required
              rows="5"
              maxlength="2000"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            ></textarea>
            <p class="text-xs text-gray-500 mt-1">{{ form.description.length }}/2000 characters</p>
          </div>

          <!-- Reported User -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Report Against (optional)
            </label>
            <input
              v-model="form.reportedUserId"
              type="text"
              placeholder="User ID or username (if known)"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p class="text-xs text-gray-500 mt-1">Leave empty if you don't know the user ID</p>
          </div>

          <!-- Attachment URL -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Attachment URL (optional)
            </label>
            <input
              v-model="form.attachmentUrl"
              type="url"
              placeholder="https://example.com/photo.jpg"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p class="text-xs text-gray-500 mt-1">Link to evidence photo or document</p>
          </div>

          <!-- Submit Button -->
          <div class="flex gap-4 pt-6">
            <button
              type="submit"
              :disabled="loading"
              class="flex-1 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-medium py-2 px-4 rounded-lg transition"
            >
              {{ loading ? 'Submitting...' : 'Submit Report' }}
            </button>
            <NuxtLink
              to="/profile"
              class="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-900 font-medium py-2 px-4 rounded-lg text-center transition"
            >
              Cancel
            </NuxtLink>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { useAuth } from '~/composables/useAuth';
import { useToast } from '~/composables/useToast';

export default {
  layout: 'default',
  middleware: 'auth',
  setup() {
    const { $api } = useNuxtApp();
    const router = useRouter();
    const { user } = useAuth();
    const toast = useToast();

    const form = ref({
      type: '',
      title: '',
      description: '',
      reportedUserId: '',
      attachmentUrl: '',
    });

    const loading = ref(false);
    const successMessage = ref('');
    const errorMessage = ref('');

    const submitReport = async () => {
      try {
        loading.value = true;
        errorMessage.value = '';
        successMessage.value = '';

        const payload = {
          type: form.value.type,
          title: form.value.title,
          description: form.value.description,
          reportedUserId: form.value.reportedUserId || undefined,
          attachmentUrl: form.value.attachmentUrl || undefined,
        };

        const response = await $api.post('/incidents', payload);

        successMessage.value = 'Incident reported successfully! Our admin team will review it shortly.';
        toast.addToast('Incident reported successfully', 'success');

        // Reset form
        form.value = {
          type: '',
          title: '',
          description: '',
          reportedUserId: '',
          attachmentUrl: '',
        };

        // Redirect after 2 seconds
        setTimeout(() => {
          router.push('/profile');
        }, 2000);
      } catch (error) {
        errorMessage.value = error.response?.data?.message || 'Failed to report incident';
        toast.addToast(errorMessage.value, 'error');
      } finally {
        loading.value = false;
      }
    };

    return {
      form,
      loading,
      successMessage,
      errorMessage,
      submitReport,
      user,
    };
  },
};
</script>

<style scoped>
</style>
