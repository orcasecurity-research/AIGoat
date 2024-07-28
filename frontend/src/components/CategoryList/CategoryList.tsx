import { ProductCategory } from '../../actions';
import CategoryItem from './CategoryItem';
import MainRowLayout from '../MainRowLayout/MainRowLayout';
import './CategoryList.less';

interface CategoryListProps {
  categories: ProductCategory[];
}

const CategoryList: React.FC<CategoryListProps> = ({ categories }) => {
  return (
    <MainRowLayout>
      {categories.map(category => {
        return <CategoryItem category={category} key={category.id} />;
      })}
    </MainRowLayout>
  );
};

export default CategoryList;
