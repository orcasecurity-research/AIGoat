import React from 'react';
import { useRouter } from 'next/router';
import { PageHeader } from 'antd';
import './MainPageHeader.less';

interface MainPageHeaderProps {
  title: string;
  subTitle?: string;
}

const MainPageHeader: React.FC<MainPageHeaderProps> = ({
  title,
  subTitle = ''
}) => {
  const router = useRouter();
  const goBack = React.useCallback(() => {
    router.back();
  }, []);

  return (
    <PageHeader
      className="site-page-header boxed-width"
      onBack={goBack}
      title={title}
      subTitle={subTitle}
    />
  );
};

export default MainPageHeader;
