import { combineReducers } from 'redux';
import ProductReducer from './product_reducer';
import CategoryReducer from './category_reducer';
import CartReducer from './cart_reducer';

export const rootReducer = combineReducers({
  product: ProductReducer,
  category: CategoryReducer,
  cart: CartReducer
});

export type AppState = ReturnType<typeof rootReducer>;
