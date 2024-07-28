import Cookies from 'js-cookie';
import { Dispatch } from 'redux';
import { CartTypes, FetchCartProducts } from '../types';
import {
  AddToCart,
  RemoveFromCart,
  UpdateCartItemCount
} from './cart_interfaces';
import { AppState } from '../../reducers';
import { orcaApi } from '../../config';

export const addToCart = (id: string, price: string, count = 1) => {
  return (dispatch: Dispatch) => {
    dispatch<AddToCart>(<AddToCart>{
      type: CartTypes.addToCart,
      payload: {id, price, count}
    });
  };
};

export const removeFromCart = (id: string) => {
  return (dispatch: Dispatch) => {
    dispatch<RemoveFromCart>(<RemoveFromCart>{
      type: CartTypes.removeFromCart,
      payload: id
    });
  };
};

export const updateCartItemCount = (
  id: string,
  price: string,
  count: number
) => {
  return (dispatch: Dispatch) => {
    dispatch<UpdateCartItemCount>(<UpdateCartItemCount>{
      type: CartTypes.updateCartItemCount,
      payload: {id, price, count}
    });
  };
};

export const fetchCartProducts = () => {

  return async (dispatch: Dispatch, getState: () => AppState) => {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) return;

      const response = await orcaApi.get('/api/cart', {
        headers: { Authorization: `Bearer ${token}` }
      });
      dispatch<FetchCartProducts>(<FetchCartProducts>{
        type: CartTypes.fetchCartProducts,
        payload: response.data
      });
    } catch (error) {
      console.log(error);
    }
  };
};
