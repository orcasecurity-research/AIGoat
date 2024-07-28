/* eslint-disable */
const withLess = require('@zeit/next-less');
const lessToJS = require('less-vars-to-js');
const fs = require('fs');
const path = require('path');
const FilterWarningsPlugin = require('webpack-filter-warnings-plugin');

// Where your antd-custom.less file lives
const themeVariables = lessToJS(
  fs.readFileSync(
    path.resolve(__dirname, './src/assets/css/antd-custom.less'),
    'utf8'
  )
);

module.exports = withLess({
  trailingSlash: true,
  output: 'export',
  env: {
    FLASK_API_URL: process.env.FLASK_API_URL
  },
  lessLoaderOptions: {
    javascriptEnabled: true,
    modifyVars: themeVariables // make your antd custom effective
  },
  webpack: (config, { isServer }) => {
    config.plugins.push(
      new FilterWarningsPlugin({
        // ignore ANTD chunk styles [mini-css-extract-plugin] warning
        exclude: /Conflicting order/
      })
    );

    if (isServer) {
      const antStyles = /antd\/.*?\/style.*?/;
      const origExternals = [...config.externals];
      config.externals = [
        (context, request, callback) => {
          if (request.match(antStyles)) return callback();
          if (typeof origExternals[0] === 'function') {
            origExternals[0](context, request, callback);
          } else {
            callback();
          }
        },
        ...(typeof origExternals[0] === 'function' ? [] : origExternals)
      ];

      config.module.rules.unshift({
        test: antStyles,
        use: 'null-loader'
      });
    }
    return config;
  }
});

// module.exports = {output: 'export'}
// module.exports = {
//   // Any existing Next.js configuration
//   trailingSlash: true, // Ensure all paths end with a trailing slash
//   exportPathMap: async function (
//     defaultPathMap,
//     { dev, dir, outDir, distDir, buildId }
//   ) {
//     return {
//       ...defaultPathMap,
//       '/': { page: '/' },
//       // Add other paths here
//     }
//   }
// };



// const withAntdLess = require('next-plugin-antd-less');
//
// module.exports = withAntdLess({
//   // Optional: Add your custom Next.js configuration here
//
//   // Enable CSS and JS minification
//   cssLoaderOptions: {
//     sourceMap: true,
//     modules: {
//       localIdentName: '[local]___[hash:base64:5]',
//     },
//   },
//
//   // Ant Design Less variables customizations (if any)
//   modifyVars: { '@primary-color': '#04f' },
//   lessVarsFilePath: './src/styles/variables.less',
//   lessVarsFilePathAppendToEndOfContent: false,
//
//   webpack(configEnv) {
//     return configEnv;
//   },
//
//   // Other Next.js configEnv options
//   trailingSlash: true,
//   exportPathMap: async function (
//     defaultPathMap,
//     { dev, dir, outDir, distDir, buildId }
//   ) {
//     return {
//       ...defaultPathMap,
//       '/': { page: '/' },
//       // Add other paths here
//     };
//   },
// });


// next.configEnv.js
// const withLess = require('@zeit/next-less');
//
// module.exports = withLess({
//   lessLoaderOptions: {
//     javascriptEnabled: true,
//   },
//   webpack(configEnv, options) {
//     configEnv.module.rules.push({
//       test: /\.less$/,
//       use: [
//         options.defaultLoaders.babel,
//         {
//           loader: require('styled-jsx/webpack').loader,
//           options: {
//             type: 'global',
//           },
//         },
//         {
//           loader: 'less-loader',
//           options: {
//             lessOptions: {
//               javascriptEnabled: true,
//             },
//           },
//         },
//       ],
//     });
//
//     return configEnv;
//   },
// });
