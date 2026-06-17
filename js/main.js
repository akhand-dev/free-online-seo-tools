/**
 * ToolNest — Global JavaScript v2.0
 * Mobile menu, toasts, scroll animations, back-to-top, cookie consent, FAQ accordion
 */
document.addEventListener('DOMContentLoaded', () => {
  initMobileMenu();
  initScrollReveal();
  initBackToTop();
  initFAQ();
  initCookieConsent();
  initServiceWorker();
});

/* ---- Service Worker ---- */
function initServiceWorker() {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/sw.js').then(registration => {
        console.log('SW registered: ', registration.scope);
      }).catch(registrationError => {
        console.log('SW registration failed: ', registrationError);
      });
    });
  }
}

/* ---- Mobile Menu ---- */
function initMobileMenu() {
  const toggle = document.getElementById('mobileMenuToggle');
  const nav = document.querySelector('.nav-links');
  if (!toggle || !nav) return;
  toggle.addEventListener('click', () => {
    toggle.classList.toggle('active');
    nav.classList.toggle('active');
  });
  document.addEventListener('click', (e) => {
    if (!toggle.contains(e.target) && !nav.contains(e.target)) {
      toggle.classList.remove('active');
      nav.classList.remove('active');
    }
  });
}

/* ---- Toast Notifications ---- */
function showToast(message, type = 'info') {
  let container = document.querySelector('.toast-container');
  if (!container) {
    container = document.createElement('div');
    container.className = 'toast-container';
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  const icons = { success: '✓', error: '✕', info: 'ℹ' };
  toast.innerHTML = `<span>${icons[type] || ''}</span> ${message}`;
  container.appendChild(toast);
  requestAnimationFrame(() => { toast.classList.add('show'); });
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

/* ---- Clipboard ---- */
async function copyToClipboard(text, btn) {
  try {
    await navigator.clipboard.writeText(text);
    if (btn) {
      const original = btn.innerText;
      btn.innerText = '✓ Copied!';
      btn.classList.add('success-state');
      setTimeout(() => { btn.innerText = original; btn.classList.remove('success-state'); }, 2000);
    }
    showToast('Copied to clipboard!', 'success');
  } catch (err) {
    showToast('Failed to copy to clipboard', 'error');
  }
}

/* ---- Scroll Reveal ---- */
function initScrollReveal() {
  const elements = document.querySelectorAll('.reveal');
  if (!elements.length) return;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });
  elements.forEach(el => observer.observe(el));
}

/* ---- Back to Top ---- */
function initBackToTop() {
  const btn = document.createElement('button');
  btn.className = 'back-to-top';
  btn.innerHTML = '↑';
  btn.setAttribute('aria-label', 'Back to top');
  document.body.appendChild(btn);
  window.addEventListener('scroll', () => {
    btn.classList.toggle('visible', window.scrollY > 400);
  });
  btn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
}

/* ---- FAQ Accordion ---- */
function initFAQ() {
  document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.parentElement;
      const wasActive = item.classList.contains('active');
      item.parentElement.querySelectorAll('.faq-item').forEach(i => i.classList.remove('active'));
      if (!wasActive) item.classList.add('active');
    });
  });
}

/* ---- Cookie Consent ---- */
function initCookieConsent() {
  if (localStorage.getItem('cookieConsent')) return;
  const banner = document.querySelector('.cookie-banner');
  if (!banner) return;
  setTimeout(() => banner.classList.add('show'), 1500);
}
function acceptCookies() {
  localStorage.setItem('cookieConsent', 'true');
  const banner = document.querySelector('.cookie-banner');
  if (banner) banner.classList.remove('show');
}

/* ---- Search Filter (homepage) ---- */
function filterTools(query) {
  const cards = document.querySelectorAll('.tool-card');
  const q = query.toLowerCase().trim();
  cards.forEach(card => {
    const text = card.textContent.toLowerCase();
    card.style.display = text.includes(q) ? '' : 'none';
  });
}

/* ---- Lazy Load AdSense ---- */
function initAdSense(publisherId) {
  setTimeout(() => {
    const script = document.createElement('script');
    script.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${publisherId}`;
    script.async = true;
    script.crossOrigin = "anonymous";
    document.head.appendChild(script);
  }, 3000);
}

const toolsList = [
    { title: "Word & Character Counter", url: "/tools/word-counter.html" },
    { title: "Case Converter", url: "/tools/case-converter.html" },
    { title: "Lorem Ipsum Generator", url: "/tools/lorem-ipsum-generator.html" },
    { title: "Text to URL Slug", url: "/tools/text-to-slug.html" },
    { title: "Markdown Preview", url: "/tools/markdown-preview.html" },
    { title: "JSON Formatter & Validator", url: "/tools/json-formatter.html" },
    { title: "JSON to CSV Converter", url: "/tools/json-to-csv.html" },
    { title: "Base64 Encoder / Decoder", url: "/tools/base64-encoder-decoder.html" },
    { title: "URL Encoder / Decoder", url: "/tools/url-encoder-decoder.html" },
    { title: "HTML Entity Encoder", url: "/tools/html-entity-encoder.html" },
    { title: "Timestamp Converter", url: "/tools/timestamp-converter.html" },
    { title: "Password Generator", url: "/tools/password-generator.html" },
    { title: "Hash Generator", url: "/tools/hash-generator.html" },
    { title: "JWT Decoder", url: "/tools/jwt-decoder.html" },
    { title: "QR Code Generator", url: "/tools/qr-code-generator.html" },
    { title: "Color Picker & Converter", url: "/tools/color-picker.html" },
    { title: "Image to Base64", url: "/tools/image-to-base64.html" },
    { title: "Image Resizer & Compressor", url: "/tools/image-resizer.html" },
    { title: "File Format Converter", url: "/tools/file-converter.html" },
    { title: "CSS Gradient Generator", url: "/tools/css-gradient-generator.html" },
    { title: "UTM Link Builder", url: "/tools/utm-link-builder.html" },
    { title: "SEO Meta Tag Generator", url: "/tools/meta-tag-generator.html" }
];

function initGlobalSearch() {
    const input = document.getElementById('globalSearch');
    const dropdown = document.getElementById('globalSearchResults');
    if (!input || !dropdown) return;
    
    input.addEventListener('input', (e) => {
        const q = e.target.value.toLowerCase().trim();
        dropdown.innerHTML = '';
        if (q.length === 0) {
            dropdown.style.display = 'none';
            return;
        }
        
        const matches = toolsList.filter(t => t.title.toLowerCase().includes(q));
        if (matches.length > 0) {
            matches.forEach(m => {
                const a = document.createElement('a');
                a.href = m.url;
                a.textContent = m.title;
                dropdown.appendChild(a);
            });
            dropdown.style.display = 'block';
        } else {
            const div = document.createElement('div');
            div.textContent = 'No tools found';
            div.style.padding = '0.5rem 1rem';
            div.style.color = 'var(--text-secondary)';
            dropdown.appendChild(div);
            dropdown.style.display = 'block';
        }
    });

    document.addEventListener('click', (e) => {
        if (!input.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });
}

function initThemeToggle() {
    const btn = document.getElementById('themeToggle');
    if (!btn) return;
    
    // Check saved theme
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'light') {
        document.body.setAttribute('data-theme', 'light');
        btn.textContent = '🌙';
    } else {
        document.body.removeAttribute('data-theme');
        btn.textContent = '☀️';
    }
    
    btn.addEventListener('click', () => {
        const currentTheme = document.body.getAttribute('data-theme') || 'dark';
        if (currentTheme === 'dark') {
            document.body.setAttribute('data-theme', 'light');
            localStorage.setItem('theme', 'light');
            btn.textContent = '🌙';
        } else {
            document.body.removeAttribute('data-theme');
            localStorage.setItem('theme', 'dark');
            btn.textContent = '☀️';
        }
    });
}

// Intercept DOMContentLoaded event in main.js to add initGlobalSearch and initThemeToggle
