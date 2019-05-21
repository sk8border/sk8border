const Mustache = require('mustache');
const fs = require('fs');
const path = require('path');

const enStrings = require('./web_template/en.json');
const frStrings = require('./web_template/fr.json');
const buildConfig = require('./build_config.json');

const template = fs.readFileSync(
  path.join(__dirname, 'web_template', 'template.html'),
  'utf-8'
);

Mustache.parse(template);

fs.writeFileSync(
  path.join(__dirname, buildConfig.html_en),
  Mustache.render(
    template,
    Object.assign(
      {},
      enStrings,
      {
        other_lang_href: buildConfig.html_fr,
        build_filename: buildConfig.build_filename
      }
    )
  )
);

fs.writeFileSync(
  path.join(__dirname, buildConfig.html_fr),
  Mustache.render(
    template,
    Object.assign(
      {},
      frStrings,
      {
        other_lang_href: buildConfig.html_en,
        build_filename: buildConfig.build_filename
      }
    )
  )
);
