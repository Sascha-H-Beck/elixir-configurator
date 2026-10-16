// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

const profectionLight = {
  primary: "oklch(50.1% 0.041 164)",
  "primary-content": "oklch(98% 0.005 165)",
  secondary: "oklch(50% 0.13 252)",
  "secondary-content": "oklch(98% 0.005 252)",
  accent: "oklch(80% 0.125 65)",
  "accent-content": "oklch(29.9% 0.067 65)",
  neutral: "oklch(50% 0.010 168)",
  "neutral-content": "oklch(98% 0 0)",
  "base-100": "oklch(98% 0.003 165)",
  "base-200": "oklch(93.5% 0.015 166)",
  "base-300": "oklch(90.1% 0.013 165)",
  "base-content": "oklch(30% 0.007 165)",
  info: "oklch(42% 0.17 258)",
  "info-content": "oklch(97% 0.014 258)",
  success: "oklch(54% 0.13 160)",
  "success-content": "oklch(98% 0.014 160)",
  warning: "oklch(68% 0.18 54)",
  "warning-content": "oklch(98% 0.015 54)",
  error: "oklch(53% 0.24 27)",
  "error-content": "oklch(96% 0.015 27)",
  "--rounded-box": "1.5rem",
  "--rounded-btn": "0.3125rem",
  "--rounded-badge": "0.3125rem",
  "--animation-btn": "0.25s",
  "--animation-input": "0.2s",
  "--btn-focus-scale": "0.95",
  "--border-btn": "1px",
  "--tab-border": "1px",
  "--tab-radius": "0.3125rem"
}

const profectionDark = {
  primary: "oklch(72.6% 0.040 164)",
  "primary-content": "oklch(30% 0.032 166)",
  secondary: "oklch(62% 0.11 252)",
  "secondary-content": "oklch(20% 0.02 252)",
  accent: "oklch(80% 0.125 65)",
  "accent-content": "oklch(29.9% 0.067 65)",
  neutral: "oklch(30% 0.007 165)",
  "neutral-content": "oklch(90.1% 0.013 165)",
  "base-100": "oklch(24% 0.007 165)",
  "base-200": "oklch(18% 0.007 165)",
  "base-300": "oklch(14% 0.007 165)",
  "base-content": "oklch(96% 0.005 165)",
  info: "oklch(58% 0.15 258)",
  "info-content": "oklch(97% 0.013 258)",
  success: "oklch(65% 0.13 160)",
  "success-content": "oklch(15% 0.02 160)",
  warning: "oklch(75% 0.16 54)",
  "warning-content": "oklch(25% 0.06 54)",
  error: "oklch(65% 0.20 27)",
  "error-content": "oklch(96% 0.015 27)",
  "--rounded-box": "1.5rem",
  "--rounded-btn": "0.3125rem",
  "--rounded-badge": "0.3125rem",
  "--animation-btn": "0.25s",
  "--animation-input": "0.2s",
  "--btn-focus-scale": "0.95",
  "--border-btn": "1px",
  "--tab-border": "1px",
  "--tab-radius": "0.3125rem"
}

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/elixirmachine_web.ex",
    "../lib/elixirmachine_web/**/*.*ex"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Ubuntu Sans Variable"', "ui-sans-serif", "system-ui", "sans-serif"]
      }
    },
  },
  daisyui: {
    themes: [
      { light: profectionLight },
      { dark: profectionDark }
    ],
    darkTheme: "dark"
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("daisyui"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
