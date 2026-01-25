/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    turbopack: true,
    turbopack: {
      root: './app'
    }
  }
}
module.exports = nextConfig
