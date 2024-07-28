import { ProductTypes } from '../types';
import axios from 'axios';
import { Dispatch } from 'redux';
import {ReactNode} from "react";

export interface ProductImage {
  id: number;
  src: string;
  alt: string;
}

export interface Product {
  id: number;
  name: string;
  slug: string;
  date_created: string;
  description: string;
  price: string;
  regular_price: string;
  sale_price: string;
  on_sale: boolean;
  related_ids: number[];
  images: ProductImage[];
}

export interface ProductComment{
  actions: ReactNode[];
  author: string;
  avatar: string;
  content: ReactNode;
  datetime: ReactNode;
}
export interface FetchSaleProducts {
  type: ProductTypes.fetchSaleProduts;
  payload: Product[];
}

export interface FetchCategoryProducts {
  type: ProductTypes.fetchCategoryProducts;
  payload: Product[];
}

export interface FetchProductById {
  type: ProductTypes.fetchProductById;
  payload: Product;
}

export interface FetchProductsByIds {
  type: ProductTypes.fetchProductsByIds;
  payload: Product[];
}

export const FETCH_PRODUCTS_BY_PHOTO_REQUEST = 'FETCH_PRODUCTS_BY_PHOTO_REQUEST';
export const FETCH_PRODUCTS_BY_PHOTO_SUCCESS = 'FETCH_PRODUCTS_BY_PHOTO_SUCCESS';
export const FETCH_PRODUCTS_BY_PHOTO_FAILURE = 'FETCH_PRODUCTS_BY_PHOTO_FAILURE';

interface FetchProductsByPhotoRequest {
  type: typeof FETCH_PRODUCTS_BY_PHOTO_REQUEST;
}

interface FetchProductsByPhotoSuccess {
  type: typeof FETCH_PRODUCTS_BY_PHOTO_SUCCESS;
  payload: any[];
}

interface FetchProductsByPhotoFailure {
  type: typeof FETCH_PRODUCTS_BY_PHOTO_FAILURE;
  payload: string;
}

export type ProductActionTypes = FetchProductsByPhotoRequest | FetchProductsByPhotoSuccess | FetchProductsByPhotoFailure;

export const fetchProductsByPhoto = (file: File) => {
  return async (dispatch: Dispatch<ProductActionTypes>) => {
    dispatch({ type: FETCH_PRODUCTS_BY_PHOTO_REQUEST });

    const formData = new FormData();
    formData.append('photo', file);

    try {
      const response = await axios.post('/api/analyze-photo', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        onUploadProgress: (progressEvent) => {
          console.log(progressEvent);
      const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
      console.log(`Upload Progress: ${percentCompleted}%`);
    },
      });
      dispatch({
        type: FETCH_PRODUCTS_BY_PHOTO_SUCCESS,
        payload: response.data,
      });
    } catch (error) {
      if (error instanceof Error) {
        dispatch({
          type: FETCH_PRODUCTS_BY_PHOTO_FAILURE,
          payload: error.message,
        });
      } else {
        dispatch({
          type: FETCH_PRODUCTS_BY_PHOTO_FAILURE,
          payload: String(error),
        });
      }
    }
  };
};