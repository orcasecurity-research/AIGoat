// @ts-nocheck
import React from 'react';
import Link from 'next/link';
import { Product } from '../../actions';
import { Typography } from 'antd';

const { Title, Text } = Typography;

interface ProductInfoProps {
  product: Product;
}

const ProductInfo: React.FC<ProductInfoProps> = ({ product }) => {
  const {
    id,
    name,
    images,
    regular_price,
    sale_price,
    on_sale,
    slug,
  } = product;
  const featured_image = images.length > 0 ? images[0].src : '';
  const product_id = `${id}`;
  return (
    <>
      <div className="featured-pp">
        <Link
          href="/product/[id]" as={`/product/${product_id}`}
        >
          <a>{featured_image && <img src={featured_image} />}</a>
        </Link>
      </div>
      <div className="description">
        <Link
          href="/product/[id]" as={`/product/${product_id}`}
        >
          <a>
            <Title level={4}>{name}</Title>
            <div>
              <Text
                type="secondary"
                delete={on_sale}
                className={`${on_sale ? 'on_sale' : 'regular'}`}
              >
                ${regular_price}
              </Text>
              {on_sale && <Text style={{ marginLeft: 10 }}>${sale_price}</Text>}
            </div>
          </a>
        </Link>
      </div>
    </>
  );
};

export default ProductInfo;
