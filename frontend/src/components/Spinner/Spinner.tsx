import { Spin } from 'antd';
import { LoadingOutlined } from '@ant-design/icons';
import './Spinner.less';

const Spinner = () => {
  return (
    <div className="spinner">
      <Spin indicator={<LoadingOutlined style={{ fontSize: 30 }} spin />} />
    </div>
  );
};

export default Spinner;
