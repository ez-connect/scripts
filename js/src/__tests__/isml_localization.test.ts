const { Localization } = require('../../lib/isml_localization');

test('read properties', () => {
  Localization.readProperties('./src/__tests__', /_en_US.properties/);
  expect(JSON.stringify(Localization.properties)).toEqual(
    JSON.stringify({
      resources: {
        'home.page.title': 'Page title',
        'home.page.content': 'Page content',
        'home.page.footer': 'Footer',
      },
    }),
  );

  Localization.patch('./src/__tests__', "Util.msg('$key', '$file')", /.*\.isml/);
});
