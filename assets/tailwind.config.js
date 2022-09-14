// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {},
    fontFamily: {
      'sans': ["YakuHanJP_Noto", "Noto Sans JP", "Hiragino Sans", "Hiragino Kaku Gothic ProN", "Meiryo", "sans-serif"],
      'serif': ["YakuHanMP_Noto", "Noto Serif JP", "Hiragino Mincho ProN", "Yu Mincho", "YuMincho", "serif"],
      'round': ["YakuHanRP", "M PLUS Rounded 1c", "Hiragino Sans", "Hiragino Kaku Gothic ProN", "Noto Sans JP", "Meiryo", "sans-serif"],
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &'])),
    require("daisyui"),
  ],
  daisyui: {
    themes: ["garden", "light", "forest", "dark"],
    darkTheme: "forest"
  }
}
