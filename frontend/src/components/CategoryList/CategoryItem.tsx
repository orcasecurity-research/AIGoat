import React from 'react';
import Link from 'next/link';
import { ProductCategory } from '../../actions';
import { Col, Card } from 'antd';
import { SkeletonListContext } from '../../contexts';
const { Meta } = Card;

interface CategoryItemProps {
  category: ProductCategory;
}

const CategoryItem: React.FC<CategoryItemProps> = ({ category }) => {
  const { xl, md, sm, lg, xs } = React.useContext(SkeletonListContext);
  const { name, description, image } = category;
  const featured_image = image?.src ?? '';

  return (
    <Col xl={xl} lg={lg} md={md} sm={sm} xs={xs} className="centered-col">
      <Link
        href="/category/[category]"
        as={`/category/${category.slug}`}
        key={category.id}
      >
        <Card
          className="category-item-card"
          hoverable
          cover={
            featured_image ? <img alt={name} src={featured_image} /> : null
          }
        >
          <Meta title={name} description={description} />
        </Card>
      </Link>
    </Col>
  );
};

export default CategoryItem;
