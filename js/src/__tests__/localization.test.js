const { Localization } = require('../../lib/localization');

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

  Localization.patch(
    './src/__tests__',
    "${Util.msg('$key', '$file')}",
    /.*\.html/,
  );
});
