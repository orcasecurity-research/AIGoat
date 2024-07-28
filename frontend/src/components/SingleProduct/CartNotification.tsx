import React from 'react';
import { notification, Button } from 'antd';
import { SmileOutlined } from '@ant-design/icons';
import Link from 'next/link';

const cartNotification = () => {
  const key = `open${Date.now()}`;
  const btn = (
    <Link href="/cart">
      <Button
        type="primary"
        size="small"
        onClick={() => notification.close(key)}
      >
        Go To Cart
      </Button>
    </Link>
  );

  notification.open({
    message: 'Item added to cart',
    description:
      'You have successfully added an item to your cart. To check out, click the button below.',
    icon: <SmileOutlined style={{ color: '#108ee9' }} />,
    top: 50,
    duration: 2,
    btn,
    key
  });
};

export default cartNotification;
