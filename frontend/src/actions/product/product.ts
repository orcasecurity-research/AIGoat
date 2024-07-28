//@ts-nocheck
import {orcaApi} from '../../config';
import { Dispatch } from 'redux';
import { ProductTypes, FetchRecommendations } from '../types';
import {
  FetchSaleProducts,
  FetchCategoryProducts,
  FetchProductById,
  FetchProductsByIds
} from './product_interfaces';
import { AppState } from '../../reducers';

export const fetchSaleProducts = (itemCount = 4) => {
  return async (dispatch: Dispatch) => {
    try {
      const response = await orcaApi.get(
        `products`
      );
      dispatch<FetchSaleProducts>(<FetchSaleProducts>{
        type: ProductTypes.fetchSaleProduts,
        // payload: (response.data && response.data.toys) || []
        payload: (response.data) || []
      });
    } catch (error) {
      console.log(error);
    }
  };
};

export const fetchCategoryProducts = (
  category: string,
  callback?: () => void
) => {
  return async (dispatch: Dispatch) => {
    try {
      const response = await orcaApi.get(`products?category=${category}`);

      dispatch<FetchCategoryProducts>(<FetchCategoryProducts>{
        type: ProductTypes.fetchCategoryProducts,
        payload: response.data
      });
      callback();
    } catch (error) {
      console.log(error);
    }
  };
};

export const fetchProductById = (id: string, callback?: () => void) => {
  return async (dispatch: Dispatch) => {
    try {

      const response = await orcaApi.get(`products/${id}`);
      dispatch<FetchProductById>(<FetchProductById>{
        type: ProductTypes.fetchProductById,
        payload: response.data
      });
      callback();
    } catch (error) {
      console.log(error);
    }
  };
};

export const fetchProductsByIds = (ids: string) => {
  return async (dispatch: Dispatch) => {
    try {
      const response = await orcaApi.get(`products?include=${ids}`);

      dispatch<FetchProductsByIds>(<FetchProductsByIds>{
        type: ProductTypes.fetchProductsByIds,
        payload: response.data
      });
    } catch (error) {
      console.log(error);
    }
  };
};

export const fetchProductsByPhoto = (formData: FormData, callback) => {
  return async (dispatch: Dispatch) => {
    try {
      const response = await orcaApi.post('/api/analyze-photo', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        timeout: 30000,
      });
      dispatch({
        type: ProductTypes.fetchProductsByPhoto,
        payload: response.data,
      });
      callback()
    } catch (error) {
      dispatch({
        type: ProductTypes.fetchProductsByPhotoError,
        payload: error,
      });
      callback()
    }
  }
};

export const fetchRecommendations = () => {
  return async (dispatch: Dispatch) => {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) {
        throw new Error('No token found');
      }

      const response = await orcaApi.get('/api/recommendations', {
        headers: { Authorization: `Bearer ${token}` },
      });

      dispatch({
        type: ProductTypes.fetchRecommendations,
        payload: response.data,
      });
    } catch (error) {
      console.error('Error fetching recommendations:', error);
    }
  };
};
