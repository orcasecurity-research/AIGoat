import React from 'react';
import { Modal } from 'antd';
import CheckoutList from './CheckoutList';
import { useProductSelector } from '../../../selectors';

interface CheckoutSummaryProps {
  visible: boolean;
  hideModal: () => void;
}

const CheckoutSummary: React.FC<CheckoutSummaryProps> = ({
  visible,
  hideModal,
}) => {
  const { cartProducts } = useProductSelector();

  return (
    <Modal
      title="Checkout Summary"
      visible={visible}
      onOk={hideModal}
      onCancel={hideModal}
      closable={false}
      width={750}
    >
      <CheckoutList products={cartProducts} />
    </Modal>
  );
};

export default CheckoutSummary;
