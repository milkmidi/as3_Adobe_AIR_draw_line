// http://eslint.org/docs/user-guide/configuring
module.exports = {
  parser: 'babel-eslint',  
  extends: 'airbnb-base',
  env: {
    browser: true,
  },
  settings: {
    'import/resolver': {
      webpack: {
        config: 'webpack.config.js',
      },
    },
  },
  globals: {
    PIXI: false,
    TweenMax: false,
    device: false,
  },
  rules: {
    'no-mixed-operators': 0,
    'no-bitwise': 0,
    'no-console': 0,
    'class-methods-use-this': 0,
    'import/prefer-default-export': 0,
    'no-plusplus': ['error', {
      allowForLoopAfterthoughts: true
    }],
  },
};