const BASE_URL = 'http://localhost:8080/api';

export const apiService = {
  async getEvents() {
    try {
      const res = await fetch(`${BASE_URL}/events`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (err) {
      console.error('Error fetching events from backend API:', err);
    }
    return [];
  },

  async getEventById(id) {
    try {
      const res = await fetch(`${BASE_URL}/events/${id}`);
      if (res.ok) return await res.json();
    } catch (err) {
      console.error(`Error fetching event ${id} from backend API:`, err);
    }
    return null;
  },

  async createEvent(eventData) {
    try {
      const res = await fetch(`${BASE_URL}/events`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData)
      });
      if (res.ok) return await res.json();
    } catch (err) {
      console.error('Error creating event in backend API:', err);
    }
    return null;
  },

  async updateEvent(eventId, eventData) {
    try {
      const res = await fetch(`${BASE_URL}/events/${eventId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData)
      });
      if (res.ok) return await res.json();
    } catch (err) {
      console.error(`Error updating event ${eventId} in backend API:`, err);
    }
    return null;
  },

  async deleteEvent(eventId) {
    try {
      const res = await fetch(`${BASE_URL}/events/${eventId}`, {
        method: 'DELETE'
      });
      if (res.ok) return await res.json();
    } catch (err) {
      console.error(`Error deleting event ${eventId} in backend API:`, err);
    }
    return { success: false };
  },

  async getRegistrations() {
    try {
      const res = await fetch(`${BASE_URL}/registrations`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (e) {
      console.error('Error fetching registrations from backend API:', e);
    }
    return [];
  },

  async createRegistration(regData) {
    try {
      const res = await fetch(`${BASE_URL}/registrations`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(regData)
      });
      if (res.ok) return await res.json();
    } catch (e) {
      console.error('Error creating registration in backend API:', e);
    }
    return null;
  },

  async updateRegistrationStatus(regId, status) {
    try {
      const res = await fetch(`${BASE_URL}/registrations/${regId}/status?status=${status}`, {
        method: 'PUT'
      });
      if (res.ok) {
        return await res.json();
      }
    } catch (e) {
      console.error(`Error updating registration ${regId} status in backend API:`, e);
    }
    return null;
  },

  async registerVolunteer(eventId, volunteerData) {
    try {
      const res = await fetch(`${BASE_URL}/events/${eventId}/volunteer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(volunteerData)
      });
      if (res.ok) return await res.json();
    } catch (err) {
      console.error('Error registering volunteer in backend API:', err);
    }
    return null;
  },

  async getVolunteers() {
    try {
      const res = await fetch(`${BASE_URL}/volunteers`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (err) {
      console.error('Error fetching volunteers from backend API:', err);
    }
    return [];
  },

  async getClubs() {
    try {
      const res = await fetch(`${BASE_URL}/clubs`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (e) {
      console.error('Error fetching clubs from backend API:', e);
    }
    return [];
  },

  async getBuildings() {
    try {
      const res = await fetch(`${BASE_URL}/buildings`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (e) {
      console.error('Error fetching buildings from backend API:', e);
    }
    return [];
  },

  async getDepartments() {
    try {
      const res = await fetch(`${BASE_URL}/auth/departments`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data)) return data;
      }
    } catch (e) {
      console.error('Error fetching departments from backend API:', e);
    }
    return [];
  }
};
