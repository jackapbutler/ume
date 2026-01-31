# UMe Website

Landing page for the UMe dating app built with Next.js 14.

## Tech Stack

- Next.js 14 (App Router)
- Tailwind CSS
- Framer Motion
- Web3Forms (waitlist)
- Google Analytics

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Variables

Create `.env.local`:

```bash
NEXT_PUBLIC_WEB3FORMS_KEY=your-web3forms-access-key
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX  # Optional
```

Get a free Web3Forms key at https://web3forms.com

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## Build for Production

```bash
npm run build
npm start
```

## Deployment

### Vercel (Recommended)

**Option 1: CLI**
```bash
npm i -g vercel
vercel
```

**Option 2: GitHub Integration**
1. Push code to GitHub
2. Import repository in Vercel dashboard
3. Add environment variables
4. Deploy automatically on push

Add environment variables in Vercel:
- Project Settings → Environment Variables
- Add `NEXT_PUBLIC_WEB3FORMS_KEY`
- Add `NEXT_PUBLIC_GA_ID` (optional)

### Custom Domain

1. **In Vercel**: Project Settings → Domains → Add Domain
2. **In DNS Provider**:
   - CNAME: `www` → `cname.vercel-dns.com`
   - A record: `@` → Vercel's IP (from dashboard)

### Other Platforms

**Netlify:**
```bash
npm run build
# Upload .next folder
```

**Static Export:**
```js
// next.config.mjs
module.exports = {
  output: 'export',
}
```
```bash
npm run build
# Deploy 'out' folder to any static host
```

## Troubleshooting

**"Module not found" errors**
- Delete `node_modules` and `.next`
- Run `npm install`

**Styles not updating**
- Clear `.next` folder: `rm -rf .next`
- Restart dev server

**Environment variables not working**
- Ensure they start with `NEXT_PUBLIC_`
- Restart dev server after changes

**Vercel deployment fails**
- Check build logs in dashboard
- Verify all environment variables are set

## License

MIT License - See LICENSE file for details.
