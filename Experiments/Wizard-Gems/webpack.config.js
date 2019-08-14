const path = require("path");
const webpack = require("webpack");
const TerserPlugin = require("terser-webpack-plugin");
const WriteFilePlugin = require("write-file-webpack-plugin");
const WebpackCleanupPlugin = require("webpack-cleanup-plugin");
const BundleAnalyzerPlugin = require("webpack-bundle-analyzer")
  .BundleAnalyzerPlugin;

const CompressionPlugin = require("compression-webpack-plugin");

module.exports = {
  entry: "./src/js/index.js",
  output: {
    path: path.resolve(__dirname, "./dist"),
    publicPath: "/dist/",
    filename: "bundle.min.js",
  },
  devServer: {
    contentBase: path.resolve(__dirname, "./"),
    publicPath: "/dist/",
    host: "127.0.0.1",
    port: 8080, // uberazariel
    // port: 3000, // razer
    open: true,
  },
  devtool: "source-map",
  mode: "development",
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              [
                "@babel/preset-env",
                {
                  targets: {
                    edge: "17",
                    firefox: "60",
                    chrome: "67",
                    safari: "11.1",
                  },
                  useBuiltIns: "usage",
                },
              ],
            ],
          },
        },
      },
      {
        test: /\.css$/,
        loaders: ["style-loader", "css-loader"],
      },
      {
        test: /\.(svg|gif|png|eot|woff|ttf)$/,
        loaders: ["url-loader"],
      },
    ],
  },
  plugins: [
    new webpack.ProvidePlugin({
      "window.jQuery": "jquery",
      "window.$": "jquery",
      jQuery: "jquery",
      $: "jquery",
    }),
    new WriteFilePlugin({
      // exclude hot-update files
      test: /^(?!.*(hot)).*/,
    }),
    new WebpackCleanupPlugin(["dist"]),
    new BundleAnalyzerPlugin(),
  ],
  resolve: {
    alias: {
      jquery: "jquery/src/jquery",
      validate: "jquery-validation/dist/jquery.validate.js",
    },
    modules: [
      path.resolve("./src/**/js/"), // path to my JS source files
      path.resolve("./node_modules/"), // path to my node modules folder
    ],
  },
};

if (process.env.NODE_ENV === "production") {
  module.exports.mode = "production";
  module.exports.devtool = "source-map";
  // http://vue-loader.vuejs.org/en/workflow/production.html
  module.exports.optimization = {
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          mangle: true,
          compress: {
            drop_console: false,
          },
        },
      }),
    ],
  };
  module.exports.plugins = (module.exports.plugins || []).concat([
    new webpack.DefinePlugin({
      "process.env": {
        NODE_ENV: '"production"',
      },
    }),
    new CompressionPlugin({
      filename: "[path].gz[query]",
      algorithm: "gzip",
      test: /\.js$|\.css$|\.html$/,
      threshold: 10240,
      minRatio: 0.8,
    }),
    new webpack.LoaderOptionsPlugin({
      minimize: true,
    }),
  ]);
}
