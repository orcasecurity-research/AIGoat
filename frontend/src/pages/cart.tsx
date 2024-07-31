// @ts-nocheck
import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import { Row, Col, Card, message, Button } from 'antd';
import Link from 'next/link';
import MainLayout from '../components/MainLayout/MainLayout';
import CartListRenderer from '../components/Cart/CartListRenderer';
import { useCartSelector, useProductSelector } from '../selectors';
import { fetchProductsByIds, fetchRecommendations, addToCart, removeFromCart, updateCartItemCount } from '../actions';
import OrderSummary from '../components/Cart/OrderSummary';
import { calculateTotalPrice, getCartIds } from '../helpers';
import { CartContext, SkeletonListContext } from '../contexts';
import './cart.less';
import { orcaApi } from '../config';

const Cart = () => {
  const { items, totalItems } = useCartSelector();
  const { cartProducts, recommendations } = useProductSelector();
  const itemsLength = items.length;

  const [totalPrice, setTotalPrice] = useState(0);
  const [loadingSuggested, setLoadingSuggested] = useState(false);

  const dispatch = useDispatch() ;

  useEffect(() => {
    if (itemsLength > 0) {
      const cartItemIds = getCartIds(items);
      dispatch(fetchProductsByIds(cartItemIds));
    }
  }, [itemsLength]);

  useEffect(() => {
    setTotalPrice(calculateTotalPrice(items));
  }, [items]);

  useEffect(() => {
    setLoadingSuggested(true);
    dispatch(fetchRecommendations())
      .then(() => setLoadingSuggested(false))
      .catch(error => {
        message.error('Failed to load suggested products');
        setLoadingSuggested(false);
        console.error('Error fetching suggested products:', error);
      });
  }, [dispatch]);

    useEffect(() => {
    // Call the image preprocessing API when the component mounts
    const endpointStatus = async () => {
      try {
        await orcaApi.post('/api/recommendations-model-endpoint-status');
      } catch (error) {
        console.error('Error fetching recommendations model endpoint status:', error);
      }
    };
    endpointStatus();
  }, []);

  return (
    <CartContext.Provider
      value={{ totalPrice }}
    >
      <SkeletonListContext.Provider
        value={{ xl: 14, lg: 24, md: 24, sm: 24, xs: 24 }}
      >
        <MainLayout title={`AI-Goat - Cart`}>
          <Row className="cart-wrapper boxed-width">
            <Col xl={14} lg={24} md={24} sm={24} xs={24}>
              <CartListRenderer
                cartProducts={cartProducts}
                totalItems={totalItems}
                onRemove={(id) => dispatch(removeFromCart(id))}
                onUpdateCount={(id, count) => dispatch(updateCartItemCount(id, count))}
              />
            </Col>
            <Col xl={10} lg={24} md={24} sm={24} xs={24}>
              <OrderSummary
                cartProducts={cartProducts}
                totalItems={totalItems}
              />
              <Card
                title={
                  <div className="suggested-products-header">
                    <h3 className="suggested-products-title">Suggested Products</h3>
                    <p className="suggested-products-subtitle">
                      The AI model takes a few minutes to learn your latest preferences...
                    </p>
                  </div>
                }
                bordered={true}
                style={{ marginTop: '20px', textAlign: 'center' }}
              >
                {loadingSuggested ? (
                  <p>Loading...</p>
                ) : (
                  <Row gutter={[16, 16]}>
                    {recommendations.map((product) => (
                      <Col key={product.id} span={12}>
                        <Card
                          hoverable
                          cover={
                            <Link href={`/product/${product.id}`} passHref>
                              <a>
                                <img alt={product.name} src={product.images[0].src} style={{ height: '150px', objectFit: 'cover', width: '100%' }} />
                              </a>
                            </Link>
                          }
                          style={{ height: '100%' }}
                        >
                          <Card.Meta title={product.name} description={product.short_description} />
                          <div style={{ marginTop: '10px', textAlign: 'center'}}>
                            <Button type="primary" onClick={() => dispatch(addToCart(product.id, product.price))}>
                              Add to Cart
                            </Button>
                          </div>
                        </Card>
                      </Col>
                    ))}
                  </Row>
                )}
              </Card>
            </Col>
          </Row>
        </MainLayout>
      </SkeletonListContext.Provider>
    </CartContext.Provider>
  );
};

export default Cart;
