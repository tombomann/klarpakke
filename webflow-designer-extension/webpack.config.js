const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'klarpakke-designer.js',
    path: path.resolve(__dirname, 'dist'),
    library: 'KlarpakkeDesigner',
    libraryTarget: 'umd',
  },
  mode: 'development',
  devtool: 'source-map',
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
  devServer: {
    port: 8080,
    hot: true,
  },
};
