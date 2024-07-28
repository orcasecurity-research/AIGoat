import React from 'react';
import { Card, List } from 'antd';
import { Product } from '../../actions';
import './SuggestedProducts.less';
import Link from 'next/link';

interface SuggestedProductsProps {
  products: Product[];
}

const SuggestedProducts: React.FC<SuggestedProductsProps> = ({ products }) => {
  return (
    <Card title="Suggested Products" className="suggested-products-card">
      <List
        dataSource={products}
        renderItem={product => (
          <List.Item>
            <List.Item.Meta
              title={<Link href={`/product/${product.id}`}>{product.name}</Link>}
              description={`$${product.price}`}
            />
          </List.Item>
        )}
      />
    </Card>
  );
};

export default SuggestedProducts;
