/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "./public/index.html",
  ],
  safelist: [
    { pattern: /(bg|text|border|ring|hover:bg|focus:border|focus:ring)-gov-.*/ },
    "font-gov",
  ],
  theme: {
    extend: {
      colors: {
        'gov-blue': '#0072BC',
        'gov-blue-dark': '#005a94',
        'gov-blue-light': '#e6f2fa',
        'gov-gray': '#f5f5f5',
        'gov-border': '#e0e0e0',
        'gov-text': '#333333',
        'gov-text-muted': '#666666',
        'gov-success': '#2e7d32',
        'gov-success-dark': '#1b5e20',
        'gov-error': '#c62828',
      },
      fontFamily: {
        gov: ['Heebo', 'Arial', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
