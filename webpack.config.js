const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const ENV = process.env.NODE_ENV || 'development';
const DEV_MODE = ENV === 'development';
console.log(`DEV_MODE:${DEV_MODE}`);

const toFilename = (name, ext = 'js') => {
  const units = [name, '.', ext];
  if (!DEV_MODE) {
    const hashStr = (ext === 'css' ? '-[contenthash]' : '-[chunkhash]');
    units.splice(1, 0, hashStr);
  }
  return units.join('');
};

module.exports = {
  context: path.join(__dirname, '/src'),
  entry: {
    app: ['./js/app.js'],
  },
  output: {
    filename: toFilename('js/[name]'),
    path: path.resolve(__dirname, 'dist'),
    publicPath: '',
  },
  resolve: {
    modules: [
      path.resolve('src/html'),
      path.resolve('src/img'),
      path.resolve('src/css'),
      path.resolve('src/js'),
      path.resolve('node_modules'),
    ],
    extensions: ['.js'],
  },
  module: {
    rules: [{
      test: /\.(js|jsx)$/,
      use: { loader: 'babel-loader' },
      exclude: /node_modules/,
    },
    {
      test: /\.scss$/,
      use: [
        'style-loader',
        {
          loader: 'css-loader',
          options: { sourceMap: true },
        },
        {
          loader: 'sass-loader',
          options: { sourceMap: true },
        },
      ],
      include: path.resolve(__dirname, 'src/css'),
      exclude: /node_modules/,
    },
    {
      test: /\.pug$/,
      use: [
        { loader: 'html-loader' },
        {
          loader: 'pug-html-loader',
          options: {
            pretty: DEV_MODE,
          },
        },
      ],
      include: path.resolve(__dirname, 'src/html'),
      exclude: /node_modules/,
    },
    {
      test: /\.(png|jpg|gif|svg|ico)$/,
      use: [
        {
          loader: 'url-loader',
          options: {
            limit: 2048,
            name: 'asset/[path][name].[ext]?[hash:10]',
          },
        },
      ],
      include: path.resolve('src/img'),
      exclude: /node_modules/,
    },
    ],
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(ENV),
    }),
    new HtmlWebpackPlugin({
      template: './html/index.pug',
    }),
  ],
  devServer: {
    contentBase: 'dist',
    port: 8080,
    stats: {
      chunks: false,
    },
    host: '0.0.0.0',
    disableHostCheck: true,
  },
  externals: {
    'pixi.js': 'PIXI',
  },
};
