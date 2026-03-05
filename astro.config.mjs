import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://yuzudraw.com',

  vite: {
    plugins: [tailwindcss()],
  },
});