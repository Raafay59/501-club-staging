/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.{erb,html}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/components/**/*.{erb,rb}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'beachday': ['Beach Day', 'Impact', 'sans-serif'],
        'titan-one': ['Titan One', 'cursive'],
        'lilita-one': ['Lilita One', 'cursive'],
      },
      boxShadow: {
        'game-glow': '0 0 20px rgba(255, 215, 0, 0.5)',
      },
      animation: {
        'fade-up':          'fadeUp 0.5s ease-out forwards',
        'fade-up-delay-1':  'fadeUp 0.5s ease-out 0.08s forwards',
        'fade-up-delay-2':  'fadeUp 0.5s ease-out 0.16s forwards',
        'fade-up-delay-3':  'fadeUp 0.5s ease-out 0.24s forwards',
        'fade-up-delay-4':  'fadeUp 0.5s ease-out 0.32s forwards',
        'float':            'float 4s ease-in-out infinite',
      },
      keyframes: {
        fadeUp: {
          '0%':   { transform: 'translate3d(0, 20px, 0)', opacity: '0' },
          '100%': { transform: 'translate3d(0, 0, 0)', opacity: '1' },
        },
        float: {
          '0%, 100%': { transform: 'translate3d(0, 0, 0)' },
          '50%':      { transform: 'translate3d(0, -6px, 0)' },
        },
      },
    },
  },
  plugins: [],
}
