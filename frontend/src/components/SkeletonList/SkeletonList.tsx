import React from 'react';
import SkeletonItem from './SkeletonItem';
import MainRowLayout from '../MainRowLayout/MainRowLayout';
import './SkeletonList.less';

interface SkeletonListProps {
  itemCount: number;
}

const SkeletonList: React.FC<SkeletonListProps> = ({ itemCount }) => {
  return (
    <MainRowLayout rowClassName="product-categories-skeleton">
      {Array.from(Array(itemCount)).map((_, i) => (
        <SkeletonItem key={i} itemCount={itemCount} />
      ))}
    </MainRowLayout>
  );
};

export default SkeletonList;
