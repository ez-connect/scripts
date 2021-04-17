const { Strapi } = require('../../lib/strapi');
const YAML = require('yaml')

test('read articles', async () => {
  const articles = YAML.stringify(await Strapi.find('articles'));
  console.log(articles);
})