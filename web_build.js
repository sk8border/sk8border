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
        build_filename: buildConfig.build_filename,
        lang_fr: JSON.stringify(false)
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
        build_filename: buildConfig.build_filename,
        lang_fr: JSON.stringify(true)
      }
    )
  )
);

fs.copyFileSync(
  path.join(__dirname, 'web_template', 'sk8border_touch_ui.js'),
  path.join(__dirname, 'sk8border_touch_ui.js')
);

fs.copyFileSync(
  path.join(__dirname, 'web_template', 'sk8border_gpio_vibrations.js'),
  path.join(__dirname, 'sk8border_gpio_vibrations.js')
);

fs.copyFileSync(
  path.join(__dirname, 'web_template', 'ChevyRay - Softsquare FR.ttf'),
  path.join(__dirname, 'ChevyRay - Softsquare FR.ttf')
);

fs.copyFileSync(
  path.join(__dirname, 'web_template', 'sk8border_logo.png'),
  path.join(__dirname, 'sk8border_logo.png')
);
