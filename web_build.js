const Mustache = require('mustache');
const fs = require('fs');
const path = require('path');
const postcss = require('postcss');
const autoprefixer = require('autoprefixer');
const cssnano = require('cssnano');

const enStrings = require('./web_template/en.json');
const frStrings = require('./web_template/fr.json');
const buildConfig = require('./build_config.json');

function getWebPathname(filename) {
  let pathname = filename;
  if (pathname.endsWith('.html')) {
    pathname = pathname.slice(0, -5);
  }
  if (pathname === 'index') {
    pathname = '.';
  }
  return pathname;
}

const template = fs.readFileSync(
  path.join(__dirname, 'web_template', 'template.html'),
  'utf-8'
);

Mustache.parse(template);

const cssPathname = path.join(__dirname, 'web_template', 'style.css');
const css = fs.readFileSync(cssPathname, 'utf-8');

postcss([autoprefixer, cssnano])
  .process(css, { from: cssPathname })
  .then(processedCss => {
    fs.writeFileSync(
      path.join(__dirname, buildConfig.html_en),
      Mustache.render(
        template,
        Object.assign(
          {},
          enStrings,
          {
            other_lang_href: getWebPathname(buildConfig.html_fr),
            build_filename: buildConfig.build_filename,
            lang_fr: JSON.stringify(false),
            inline_css: processedCss
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
            other_lang_href: getWebPathname(buildConfig.html_en),
            build_filename: buildConfig.build_filename,
            lang_fr: JSON.stringify(true),
            inline_css: processedCss
          }
        )
      )
    );
  });

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
