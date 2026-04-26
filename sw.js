// ============================================================================
// 林ファミリー English — Service Worker
//
// Goal: the app works fully offline once it's been opened online once.
//
// Strategy
//   - HTML (the app shell)         → network-first, cache fallback
//   - Same-origin static assets    → cache-first, network fallback
//   - Cross-origin CDN + fonts     → cache-first, network fallback
//   - api.anthropic.com            → never cached (always network)
//
// Cache version: bump CACHE_VERSION whenever the prebake list or fetch
// behaviour needs to invalidate previously-cached files.
// ============================================================================

const CACHE_VERSION = 'hfe-v3-2026-04-26';

// Files to proactively cache on install. Everything else is cached lazily
// the first time it's requested while online.
const PRECACHE_URLS = [
  './HayashiFamilyEnglish.html',
  './hfe-icon.svg',
  // React 18 from CDN (used by the app at runtime)
  'https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js',
  // Supabase JS SDK
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
  // Google Fonts stylesheet (font files themselves are cached lazily)
  'https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600&family=DM+Sans:wght@400;500;600;700&family=Noto+Sans+JP:wght@300;400;500;600;700&family=Shippori+Mincho:wght@400;500;600;700&display=swap',
];

// ----- install: prebake the shell -----
self.addEventListener('install', (event) => {
  // Activate this SW immediately on next page load instead of waiting for
  // every tab to close.
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) =>
      // Use individual put() so one failed CDN URL doesn't abort the whole
      // install. addAll() is atomic and would fail the whole install on a
      // single 404 / cors / offline error.
      Promise.all(
        PRECACHE_URLS.map((url) =>
          fetch(url, { mode: 'no-cors' }).then((res) => {
            if (res && (res.ok || res.type === 'opaque')) {
              return cache.put(url, res.clone());
            }
          }).catch(() => { /* ignore — will be cached lazily on first use */ })
        )
      )
    )
  );
});

// ----- activate: drop old caches + take control of open tabs -----
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

// ----- fetch: network-first for HTML, cache-first for everything else -----
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Only handle GETs. Anything else (POST to Anthropic API, etc.) goes
  // straight to network with no SW intervention.
  if (req.method !== 'GET') return;

  let url;
  try { url = new URL(req.url); } catch { return; }

  // Never touch the Anthropic API.
  if (url.hostname === 'api.anthropic.com') return;

  const isHTML =
    req.mode === 'navigate' ||
    url.pathname.endsWith('.html') ||
    (req.headers.get('accept') || '').includes('text/html');

  if (isHTML) {
    event.respondWith(networkFirst(req));
  } else {
    event.respondWith(cacheFirst(req));
  }
});

// ============================================================================
// Strategies
// ============================================================================

// network-first: try network; on success update cache; on failure fall back
// to the cache (ignoring ?_=timestamp cache-bust suffixes).
function networkFirst(req) {
  return fetch(req)
    .then((res) => {
      if (res && res.status === 200) {
        const copy = res.clone();
        caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
      }
      return res;
    })
    .catch(() =>
      caches.match(req, { ignoreSearch: true }).then((hit) =>
        hit || caches.match('./HayashiFamilyEnglish.html', { ignoreSearch: true })
      )
    );
}

// cache-first: serve from cache when present; otherwise fetch and cache the
// result for next time. Tolerant of opaque (cross-origin) responses so CDN
// scripts still work offline.
function cacheFirst(req) {
  return caches.match(req).then((hit) => {
    if (hit) return hit;
    return fetch(req).then((res) => {
      if (res && (res.ok || res.type === 'opaque')) {
        const copy = res.clone();
        caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
      }
      return res;
    }).catch(() => caches.match(req, { ignoreSearch: true }));
  });
}

// ----- message: allow the page to ask the SW to skip waiting -----
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});
