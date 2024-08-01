// @ts-nocheck
import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Row, Col, Upload, Button, List, message, Spin } from 'antd';
import { UploadOutlined } from '@ant-design/icons';
import MainLayout from '../components/MainLayout/MainLayout';
import {fetchCategoryProducts, fetchProductsByPhoto} from '../actions';
import { AppState } from '../reducers';
import ProductListRenderer from "../components/ProductList/ProductListRenderer";
import {orcaApi} from "../config";

const ProductSearch = () => {
  const [file, setFile] = useState<File | null>(null);
  const dispatch = useDispatch();
  const { productsByPhoto, error, loading } = useSelector((state: AppState) => state.product);
  const [isLoading, setLoading] = useState(false);

  useEffect(() => {
    // Call the image preprocessing API when the component mounts
    const preprocessImages = async () => {
      try {
        await orcaApi.post('/api/image-preprocessing');
      } catch (error) {
        console.error('Error preprocessing images:', error);
      }
    };
    preprocessImages();
  }, []);

  const handleUpload = () => {
    if (file) {
      const formData = new FormData();
      formData.append('photo', file);
      setLoading(true);
      dispatch(
        fetchProductsByPhoto(formData, () => {
          setLoading(false);
        })
      );

    } else {
      message.error('Please upload a photo.');
    }
  };

  const props = {
    beforeUpload: (file: File) => {
      setFile(file);
      return false;
    },
    fileList: file ? [file] : [],
  };

  const containerStyle: React.CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    // height: 'calc(100vh - 64px)', // Full height of the viewport minus the height of the navbar
    marginTop: '64px', // Adjust the top margin as needed
    marginBottom: '35px',
  };

  return (
    <MainLayout title="AI-Goat - Product Search">
      <Row style={containerStyle}>
        <Col span={24} style={{ textAlign: 'center' }}>
          <Upload {...props}>
            <Button icon={<UploadOutlined />}>Upload Photo</Button>
          </Upload>
          <p style={{ marginTop: '8px', fontSize: '14px', color: '#888' }}>
            Supported file types: jpg, jpeg
          </p> {/* Added line for supported extensions */}
          <Button type="primary" onClick={handleUpload} style={{ marginTop: 16 }}>
            Search Products
          </Button>
          {error && <p>Error: {error.message}</p>}
        </Col>
      </Row>
      <Spin spinning={isLoading}> {/* Changed line */}
        {productsByPhoto && productsByPhoto.length > 0 && (
          <ProductListRenderer
            skeleton
            skeletonCount={4}
            spin={isLoading}
            products={productsByPhoto}
            breakpoints={{ xl: 6, lg: 6, md: 6, sm: 12, xs: 24 }}
          />
        )}
      </Spin> {/* Changed line */}
    </MainLayout>
  );
};

export default ProductSearch;
