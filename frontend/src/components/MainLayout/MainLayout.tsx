import HeaderMeta from './HeaderMeta';
import MainNav from './MainNav/MainNav';
import MainFooter from './MainFooter';
import { Layout } from 'antd';

const { Content } = Layout;

interface LayoutProps {
  children: React.ReactNode;
  title: string;
}

const MainLayout: React.FC<LayoutProps> = ({ children, title }) => {
  return (
    <>
      <HeaderMeta title={title} />
      <Layout>
        <MainNav />
        <Content style={{ minHeight: '500px' }}>{children}</Content>
        <MainFooter />
      </Layout>
    </>
  );
};

export default MainLayout;
