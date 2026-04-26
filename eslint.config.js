import tseslint from 'typescript-eslint';
import tsdoc from 'eslint-plugin-tsdoc';

export default tseslint.config(
  {
    ignores: ['node_modules/**', 'dist/**', 'docs-site/**', 'reports/**', 'eslint.config.js'],
  },
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/require-await': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'tsdoc/syntax': 'error',
    },
    plugins: {
      tsdoc,
    },
  },
);
