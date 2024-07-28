import { Layout } from 'antd';
const { Footer } = Layout;

const MainFooter = () => {
  return (
    <Footer style={{ textAlign: 'center', marginTop: 50 }}>
      AI Goat ©{new Date().getFullYear()} Created by {' '}
      <a href="https://orca.security/" target="_blank">
        @Orca Security
      </a>
    </Footer>
  );
};

export default MainFooter;
