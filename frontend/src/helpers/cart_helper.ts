import Cookies from 'js-cookie';
import { Product, Cart } from '../actions';

//Cookies.remove(CART_ITEMS);

export const CART_ITEMS = 'CART_ITEMS';
export const CART_ITEMS_DELIMETER = ',';

export const calculateTotalPrice = (cartItems: Cart[]): number => {
  let totalPrice = 0;
  cartItems.map(item => {
    totalPrice += Number(item.price) * item.count;
  });
  return totalPrice;
};

export const getCartIds = (cartItems: Cart[]): string => {
  let cartItemIds = cartItems.map(item => item.id);
  return cartItemIds.join(CART_ITEMS_DELIMETER);
};

export const getCartItemCount = (
  cartItems: Cart[],
  currentProductId: number
): number => {
  return cartItems.find(item => item.id === currentProductId)?.count || 0;
};

export const stringifyArr = (cartItems: Cart[]): string => {
  return cartItems
    .map((item: Cart) => {
      return `${item.id}-${item.price}-${item.count}`;
    })
    .join(CART_ITEMS_DELIMETER);
};

export const saveToCartCookie = (cartItems: Cart[]) => {
  Cookies.set(CART_ITEMS, stringifyArr(cartItems), { expires: 7 });
};

export const getCartCookie = (): string => {
  return Cookies.get(CART_ITEMS) || '';
};

export const getCartCookieArr = (): Cart[] => {
  const cartCookieStr = getCartCookie();
  const cartItems = cartCookieStr
    ? cartCookieStr.split(CART_ITEMS_DELIMETER)
    : [];
  let items: (Cart | { price: string; count: number; id: number })[] = [];
  if (cartItems.length > 0) {
    cartItems.forEach((cartItem, i) => {
      const cartItemPieces = cartItem.split('-');
      items = [
        ...items,
        {
          id: parseInt(cartItemPieces[0]),
          price: cartItemPieces[1],
          count: Number(cartItemPieces[2])
        }
      ];
    });
  }

  return items;
};

export const getTotalItemsCookie = (): number => {
  const items = getCartCookie();
  return items ? items.split(CART_ITEMS_DELIMETER).length : 0;
};

export const getItemIndex = (cartItems: Cart[], id: number | string) => {
  return cartItems.map(item => item.id).indexOf(Number(id));  // Ensure id is a number
};

export const removeItem = (cartItems: Cart[], id: number) => {
  const index = getItemIndex(cartItems, id);
  if (index > -1) {
    cartItems.splice(index, 1);
  }
  return cartItems;
};

export const updateCartItemCount = (
  cartItems: Cart[],
  index: number,
  count: number
) => {
  return cartItems.map((item, i) => {
    return i === index ? { ...item, count: item.count + count } : item;
  });
};
