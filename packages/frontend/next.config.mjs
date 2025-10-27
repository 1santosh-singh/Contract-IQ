// next.config.mjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone', // Enable standalone output for Docker
  experimental: {
    serverComponentsExternalPackages: ['pdf-parse', 'mammoth'],
  },
};

export default nextConfig;