import React, { useState, useEffect } from 'react';
// @ts-ignore
import Progress from 'react-progress';
import Router from 'next/router';

const ProgressLine = () => {
  const [percent, setPercent] = useState(0);

  useEffect(() => {
    Router.events.on('routeChangeStart', () => {
      setPercent(95);
    });
    Router.events.on('routeChangeComplete', () => {
      setPercent(100);
    });
  });

  return (
    <div className="loading-bar" style={{ position: 'fixed' }}>
      <Progress percent={percent} height={2} />
    </div>
  );
};

export default ProgressLine;
