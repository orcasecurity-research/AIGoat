// @ts-nocheck
import {
  Cart,
  RemoveFromCart,
  AddToCart,
  CartTypes,
  UpdateCartItemCount
} from '../actions';
import {
  getTotalItemsCookie,
  getCartCookieArr,
  getItemIndex,
  updateCartItemCount,
  saveToCartCookie,
  removeItem
} from '../helpers';

type Actions = AddToCart | RemoveFromCart | UpdateCartItemCount;

export interface CartState {
  totalItems: number;
  items: Cart[];
}

export const initialState: CartState = {
  totalItems: getTotalItemsCookie(),
  items: getCartCookieArr()
};

export default function(state = initialState, action: Actions) {
  switch (action.type) {
    case CartTypes.addToCart:
    case CartTypes.updateCartItemCount:
      const cartItem = action.payload;
      const index = getItemIndex(state.items, cartItem.id);
      const currentItems = state.items;

      let cartItems: Cart[] = [];

      // if item already exists increase count
      if (index > -1) {
        cartItems = updateCartItemCount(
          [...currentItems],
          index,
          cartItem.count
        );
      } else {
        cartItems = [...currentItems, action.payload];
      }

      saveToCartCookie(cartItems);

      return { ...state, items: cartItems, totalItems: cartItems.length };

    case CartTypes.removeFromCart:
      const item = action.payload;
      const items = [...state.items];
      const filteredItems = removeItem(items, item);
      saveToCartCookie(filteredItems);

      return {
        ...state,
        items: filteredItems,
        totalItems: filteredItems.length
      };

    default:
      return state;
  }
}
