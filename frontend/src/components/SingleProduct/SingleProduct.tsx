import React from 'react';
import { Row, Col, Typography, Descriptions, Button } from 'antd';
import cartNotification from './CartNotification';
import { Product, addToCart } from '../../actions';
import { useDispatch } from 'react-redux';
import { SingleProductContext } from '../../contexts';
import './SingleProduct.less';

const { Text } = Typography;
const { Item } = Descriptions;

interface SingleProductProps {
  product: Product;
}

const SingleProduct: React.FC<SingleProductProps> = ({ product }) => {
  const breakpoints = React.useContext(SingleProductContext);
  const dispatch = useDispatch();

  const {
    id,
    name,
    // @ts-ignore
    description,
    images,
      // @ts-ignore
    regular_price,
    // @ts-ignore
    sale_price,
      // @ts-ignore
    on_sale,
    price
  } = product;
  const productId = `${id}`;
  const featured_image = images.length > 0 ? images[0].src : '';

  const addItemToCart = () => {
    dispatch(addToCart(productId, price));
    cartNotification();
  };

  return (
    <>
      <Row className="product-wrapper" justify="space-around">
        <Col
          xl={breakpoints[0].xl}
          lg={breakpoints[0].lg}
          md={breakpoints[0].md}
          sm={breakpoints[0].sm}
          className="product-image"
        >
          {featured_image && <img src={featured_image} />}
        </Col>
        <Col
          xl={breakpoints[1].xl}
          lg={breakpoints[1].lg}
          md={breakpoints[1].md}
          sm={breakpoints[1].sm}
          className="product-description"
        >
          <Descriptions title={name} column={1}>
            <Item key="price" label="Price" className="price-description">
              <Text
                type="secondary"
                delete={on_sale}
                className={`${on_sale ? 'on_sale' : 'regular'}`}
              >
                ${regular_price}
              </Text>
              {on_sale && <Text style={{ marginLeft: 15 }}>${sale_price}</Text>}
            </Item>
            <Item key="desc" label="Description">
              <p dangerouslySetInnerHTML={{ __html: description }} />
            </Item>
            <Item key="button" label="">
              <Button type="primary" onClick={addItemToCart}>
                Add To Cart
              </Button>
            </Item>
          </Descriptions>
        </Col>
      </Row>
    </>
  );
};

export default SingleProduct;
