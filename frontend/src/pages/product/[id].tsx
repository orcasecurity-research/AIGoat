// @ts-nocheck
import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { useDispatch } from 'react-redux';
import MainLayout from '../../components/MainLayout/MainLayout';
import SingleProductRenderer from '../../components/SingleProduct/SingleProductRenderer';
import { useProductSelector } from '../../selectors';
import { fetchProductById } from '../../actions';
import { Row, Comment, Avatar, Form, Input, Skeleton } from 'antd';
import Comments from "../../components/Comments/Comments";
const { TextArea } = Input;
const { Button } = Skeleton;

const Product = () => {
  const [isLoading, setLoading] = useState(false);

  const router = useRouter();
  const { id: productParam } = router.query;
  const productId = productParam ? productParam : null;

  const { currentProduct } = useProductSelector();
  const currentProductId = `${currentProduct?.id ?? ''}`;
  const currentProductName = currentProduct?.name ?? '...';

  const dispatch = useDispatch();

  useEffect(() => {
    if (productId && productId !== currentProductId) {
      setLoading(true);
      dispatch(
          // @ts-ignore
        fetchProductById(productId, () => {
          setLoading(false);
        })
      );
    }
  }, [productId]);

  return (
    <MainLayout title={`AI-Goat - ${currentProductName}`}>
      <SingleProductRenderer
        product={currentProduct}
        loading={isLoading}
        breakpoints={[
          { xl: 10, lg: 10, md: 10, sm: 24, xs: 0 },
          { xl: 14, lg: 14, md: 14, sm: 24, xs: 0 }
        ]}
      />
      <Row
        align="middle"
        justify={"space-around"}
        style={{
          marginTop: 0,
          background: 'white',
          // borderRadius: borderRadiusLG,
          // paddingRight: 200,
          // paddingLeft: 200,
        }}
      >
          {productId && (<Comments productId={Number(productId)} />)}
      </Row>
      <Row
        align="middle"
        justify={"space-around"}
        style={{
          marginTop: 0,
          background: 'white',
          // borderRadius: borderRadiusLG,
          // paddingRight: 200,
          // paddingLeft: 200,
        }}
      >
      </Row>
    </MainLayout>
  );
};

export default Product;
