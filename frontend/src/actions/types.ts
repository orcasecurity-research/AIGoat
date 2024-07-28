// import {Id} from "./product/product_interfaces";

export enum ProductTypes {
  fetchSaleProduts = 'FETCH_SALE_PRODUCTS',
  fetchCategoryProducts = 'FETCH_CATEGORY_PRODUCTS',
  fetchProductById = 'FETCH_PRODUCT_BY_ID',
  fetchProductsByIds = 'FETCH_PRODUCTS_BY_IDS',
  fetchProductsByPhoto = 'FETCH_PRODUCTS_BY_PHOTO',
  fetchProductsByPhotoError = 'FETCH_PRODUCTS_BY_PHOTO_ERROR',
  fetchRecommendations = 'FETCH_RECOMMENDATIONS',
}

export enum CategoryTypes {
  fetchMainProductCategories = 'FETCH_MAIN_PRODUCT_CATEGORIES',
  fetchCategory = 'FETCH_CATEGORY'
}

export enum CartTypes {
  addToCart = 'ADD_TO_CART',
  removeFromCart = 'REMOVE_FROM_CART',
  updateCartItemCount = 'UPDATE_CART_ITEM_COUNT',
  fetchCartProducts = 'FETCH_CART_PRODUCTS',
  fetchRecommendations = 'FETCH_RECOMMENDATIONS'
}


export interface FetchRecommendations {
  type: ProductTypes.fetchRecommendations;
  payload: Product[];
}

export interface FetchCartProducts {
  type: CartTypes.fetchCartProducts;
  payload: Product[];
}

// ... other types
export interface Product {
  id: string;
  name: string;
  slug: string;
  price: string;
  short_description: string;
  images: { src: string }[];
  categories: { name: string }[];
}

export interface Cart {
  id: number;
  price: string;
  count: number;
}

export interface CartState {
  totalItems: number;
  items: Cart[];
  cartProducts: Product[];
  recommendations: Product[];
}

export interface FetchCartProducts {
  type: CartTypes.fetchCartProducts;
  payload: Product[];
}

export interface FetchRecommendations {
  type: ProductTypes.fetchRecommendations;
  payload: Product[];
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
  payload: { id: string; price: string; count: number };
}
