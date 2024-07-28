import { CategoryTypes } from '../types';

export interface ProductCategory {
  id: number;
  name: string;
  slug: string;
  description: string;
  parent: number;
  count: number;
  image: {
    id: number;
    src: string;
  };
}

export interface FetchMainProductCategories {
  type: CategoryTypes.fetchMainProductCategories;
  payload: ProductCategory[];
}

export interface FetchCategory {
  type: CategoryTypes.fetchCategory;
  payload: ProductCategory;
}
