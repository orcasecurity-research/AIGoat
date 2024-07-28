import React, { useState } from 'react';
import { Typography, Button } from 'antd';
import { Product } from '../../actions';
import { CartContext } from '../../contexts';
import CheckoutModal from './Checkout/CheckoutModal';

const { Title, Text } = Typography;

interface OrderSummaryProps {
  cartProducts: Product[];
  totalItems: number;
}

const OrderSummary: React.FC<OrderSummaryProps> = ({
  cartProducts,
  totalItems,
}) => {
  const { totalPrice } = React.useContext(CartContext);
  const [modalVisibility, setModalVisibility] = useState(false);

  return (
    <div className="order-summary">
      <Title level={3}>Order Summary</Title>
      <div>
        <Text type="secondary">Total</Text>
        <Text disabled={cartProducts.length === 0}>₱{Number(totalPrice)}</Text>
      </div>
      <Button
        type="primary"
        size="large"
        disabled={cartProducts.length === 0 || totalItems === 0}
        onClick={() => setModalVisibility(true)}
      >
        CHECKOUT
      </Button>
      <CheckoutModal
        visible={modalVisibility}
        hideModal={() => setModalVisibility(false)}
      />
    </div>
  );
};

export default OrderSummary;
