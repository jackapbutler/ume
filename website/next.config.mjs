const nextConfig = {
    output: 'export',
    images: {
        unoptimized: true,
        // Add image domains for external sources
        domains: ['images.unsplash.com'],
        // Enable modern image formats
        formats: ['image/webp', 'image/avif'],
    },
    // Enable compression
    compress: true,
    // Enable React strict mode for better development experience
    reactStrictMode: true,
};

export default nextConfig;