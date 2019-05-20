module.exports = {
  'src/**/*.js': ['npm run compliance:lint'],
  'tests/**/*.js': ['npm run compliance:lint'],
  'package.json': ['npm run security:outdated', 'npm run security:audit'],
};
