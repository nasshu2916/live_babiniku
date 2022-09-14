module.exports = {
  // root: true,
  env: {
    browser: true,
    node: true,
    es2021: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/recommended",
    "prettier",
  ],
  parserOptions: {
      ecmaVersion: 2020,
      sourceType: 'module'
  },
  rules: {
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
  },
}
