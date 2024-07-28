import React from 'react';
import { Product } from '../../actions';
import CartList from './CartList';
import SkeletonList from '../SkeletonList/SkeletonList';

interface CartListRendererProps {
  cartProducts: Product[];
  totalItems: number;
}

const CartListRenderer: React.FC<CartListRendererProps> = ({
  cartProducts,
  totalItems
}) => {
  return (
    <>
      {cartProducts.length > 0 && totalItems > 0 ? (
        <CartList products={cartProducts} />
      ) : (
        <SkeletonList itemCount={totalItems} />
      )}
    </>
  );
};

export default CartListRenderer;
