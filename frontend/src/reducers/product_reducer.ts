// @ts-nocheck
import {
  ProductTypes,
  Product,
  FetchSaleProducts,
  FetchCategoryProducts,
  FetchProductById,
  FetchProductsByIds,
  ProductActionTypes,
  FETCH_PRODUCTS_BY_PHOTO_REQUEST,
  FETCH_PRODUCTS_BY_PHOTO_SUCCESS,
  FETCH_PRODUCTS_BY_PHOTO_FAILURE,
  FetchRecommendations
} from '../actions';

type Actions =
  | FetchSaleProducts
  | FetchCategoryProducts
  | FetchProductById
  | FetchProductsByIds
  | ProductActionTypes
  | FetchRecommendations
  | { type: ProductTypes.fetchRecommendations; payload: Product[] };


export interface ProductState {
  saleProducts: Product[];
  categoryProducts: Product[];
  currentProduct?: Product;
  cartProducts: Product[];
  productsByPhoto: Product[];
  loading: boolean;
  recommendations: Product[];
  error: string | null;
}

export const initialState: {
  categoryProducts: any[];
  cartProducts: any[];
  currentProduct: undefined;
  loading: boolean;
  error: null;
  saleProducts: any[];
  productsByPhoto: any[];
  recommendations: any
} = {
  saleProducts: [],
  categoryProducts: [],
  cartProducts: [],
  currentProduct: undefined,
  productsByPhoto: [],
  loading: false,
  error: null,
  recommendations: [],
};

export default function(state = initialState, action: Actions) {
  switch (action.type) {
    case ProductTypes.fetchSaleProduts:
      return {
        ...state,
        saleProducts: action.payload
      };
    case ProductTypes.fetchCategoryProducts:
      return { ...state, categoryProducts: action.payload };
    case ProductTypes.fetchProductById:
      return { ...state, currentProduct: action.payload };
    case ProductTypes.fetchProductsByIds:
      return { ...state, cartProducts: action.payload };
    case ProductTypes.fetchProductsByPhoto:
      return { ...state, productsByPhoto: action.payload };
    case FETCH_PRODUCTS_BY_PHOTO_REQUEST:
      return { ...state, loading: true, error: null };
    case FETCH_PRODUCTS_BY_PHOTO_SUCCESS:
      return { ...state, loading: false, productsByPhoto: action.payload };
    case FETCH_PRODUCTS_BY_PHOTO_FAILURE:
      return { ...state, loading: false, error: action.payload };
    case ProductTypes.fetchRecommendations:
      return {
        ...state,
        recommendations: action.payload
      };
    default:
      return state;
  }
}