import { CartTypes } from '../types';

export interface Cart {
  id: string;
  price: string;
  count: number;
}

export interface AddToCart {
  type: CartTypes.addToCart;
  payload: Cart;
}

export interface RemoveFromCart {
  type: CartTypes.removeFromCart;
  payload: string;
}

export interface UpdateCartItemCount {
  type: CartTypes.updateCartItemCount;
  payload: Cart;
}
