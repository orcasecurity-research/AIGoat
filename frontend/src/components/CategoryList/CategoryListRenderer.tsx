import React from 'react';
import CategoryList from './CategoryList';
import SkeletonList from '../SkeletonList/SkeletonList';
import { ProductCategory } from '../../actions';
import { SkeletonListContext, Breakpoints } from '../../contexts';

interface CategoryListRendererProps {
  categories: ProductCategory[];
  breakpoints: Breakpoints;
}

const CategoryListRenderer: React.FC<CategoryListRendererProps> = ({
  categories,
  breakpoints
}) => {
  return (
    <SkeletonListContext.Provider value={breakpoints}>
      {categories.length === 0 ? (
        <SkeletonList itemCount={3} />
      ) : (
        <CategoryList categories={categories} />
      )}
    </SkeletonListContext.Provider>
  );
};

export default CategoryListRenderer;
