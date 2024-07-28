import React from 'react';
import { Row, Col, Skeleton } from 'antd';
import { SingleProductContext } from '../../../contexts';
import './SingleProductSkeleton.less';

const { Button } = Skeleton;

const SingleProductSkeleton: React.FC = () => {
  const breakpoints = React.useContext(SingleProductContext);

  return (
    <Row className="product-skeleton-wrapper" justify="space-around">
      <Col
        xl={breakpoints[0].xl}
        lg={breakpoints[0].lg}
        md={breakpoints[0].md}
        sm={breakpoints[0].sm}
        className="product-skeleton-image"
      >
        <Skeleton
          loading={true}
          active
          avatar={{ shape: 'square' }}
          paragraph={false}
          title={false}
        />
      </Col>
      <Col
        xl={breakpoints[1].xl}
        lg={breakpoints[1].lg}
        md={breakpoints[1].md}
        sm={breakpoints[1].sm}
        className="product-skeleton-description"
      >
        <Skeleton
          loading={true}
          active
          avatar={false}
          paragraph={{
            rows: 5,
            width: ['50%', '30%', '100%', '100%', '100%']
          }}
          title={{ width: '70%' }}
        />
        <Button active size="large" />
      </Col>
    </Row>
  );
};

export default SingleProductSkeleton;
