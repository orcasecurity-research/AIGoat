// @ts-nocheck
import React from 'react';
import { AppProps } from 'next/app';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import { rootReducer } from '../reducers';
import ProgressLine from '../components/ProgressLine';
import './app.less';

const store = createStore(rootReducer, applyMiddleware(thunk));

const App = ({ Component, pageProps }: AppProps) => {
  return (
    <Provider store={store}>
      <ProgressLine />
      <Component {...pageProps} />
    </Provider>
  );
};

export default App;
