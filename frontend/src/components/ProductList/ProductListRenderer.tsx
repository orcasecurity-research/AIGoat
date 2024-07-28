import React from 'react';
import ProductList from './ProductList';
import Spinner from '../Spinner/Spinner';
import { Product } from '../../actions';
import SkeletonList from '../SkeletonList/SkeletonList';
import { SkeletonListContext, Breakpoints } from '../../contexts';

interface ProductListRendererProps {
  products: Product[];
  skeletonCount?: number;
  skeleton?: boolean;
  spin?: boolean;
  breakpoints: Breakpoints;
}

const ProductListRenderer: React.FC<ProductListRendererProps> = ({
  products,
  skeleton,
  skeletonCount = 0,
  spin,
  breakpoints
}) => {

  return (
    <SkeletonListContext.Provider value={breakpoints}>
      {skeleton && products.length === 0 && (
        <SkeletonList itemCount={skeletonCount} />
      )}
      {products.length > 0 && !spin && <ProductList products={products} />}
      {spin && <Spinner />}
    </SkeletonListContext.Provider>
  );
};

export default ProductListRenderer;
