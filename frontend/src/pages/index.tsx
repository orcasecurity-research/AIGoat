import React, { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import MainLayout from '../components/MainLayout/MainLayout';
import MainCarousel from '../components/MainCarousel/MainCarousel';
import CategoryListRenderer from '../components/CategoryList/CategoryListRenderer';
import ProductListRenderer from '../components/ProductList/ProductListRenderer';
import SimpleHeading from '../components/SimpleHeading';
import { fetchMainProductCategories, fetchSaleProducts } from '../actions';
import { useCategorySelector, useProductSelector } from '../selectors';

const Home = () => {
  const dispatch = useDispatch();
  const { saleProducts } = useProductSelector();
  const { mainCategories } = useCategorySelector();
        // console.log('saleProducts', saleProducts)

  useEffect(() => {
    dispatch(fetchMainProductCategories());
    dispatch(fetchSaleProducts());
  }, []);

  return (
    <MainLayout title="AI-Goat">
      <MainCarousel />

      <SimpleHeading title="Product Categories" />
      <CategoryListRenderer
        categories={mainCategories}
        breakpoints={{
          xl: 8,
          lg: 8,
          md: 8,
          sm: 24,
          xs: 24
        }}
      />

      <SimpleHeading title="On sale Products" level={2} />

      <ProductListRenderer
        skeleton
        skeletonCount={4}
        products={saleProducts}
        breakpoints={{ xl: 6, lg: 6, md: 6, sm: 12, xs: 24 }}
      />
    </MainLayout>
  );
};

export default Home;
