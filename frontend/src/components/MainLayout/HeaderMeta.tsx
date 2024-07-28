import Head from 'next/head';

interface HeaderMetaProps {
  title: string;
}

const HeaderMeta: React.FC<HeaderMetaProps> = ({ title }) => {
  return (
    <Head>
      <title>{title}</title>
      <meta charSet="utf-8" />
      <meta name="viewport" content="initial-scale=1.0, width=device-width" />
    </Head>
  );
};

export default HeaderMeta;
