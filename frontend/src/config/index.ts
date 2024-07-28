//@ts-nocheck
import axios from 'axios';

// const FLASK_API_URL = 'http://44.213.80.217:8000'
// const FLASK_API_URL = process.env.NEXT_PUBLIC_FLASK_API_URL || 'http://127.0.0.1:8000';
const FLASK_API_URL = "PLACE_HOLDER";

// export const orcaApi = axios.create({
//   baseURL: FLASK_API_URL,
//   timeout: 1000,
//   headers: {
//     'Content-Type': 'application/json',
//   },
// });
export const getToken = () => {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('token');
  }
  return null;
};

export const orcaApi = axios.create({
  baseURL: FLASK_API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

orcaApi.interceptors.request.use(
  config => {
    const token = getToken();
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);
