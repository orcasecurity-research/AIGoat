import { useSelector } from 'react-redux';
import { AppState } from '../reducers';

export const useProductSelector = () =>
  useSelector((state: AppState) => state.product);
export const useCategorySelector = () =>
  useSelector((state: AppState) => state.category);
export const useCartSelector = () =>
  useSelector((state: AppState) => state.cart);

