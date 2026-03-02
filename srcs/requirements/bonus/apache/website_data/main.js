/* main.js — RDNA 4 site shared scripts */

// ─── Animated Bars on Scroll ─────────────────────────────────
(function () {
  const fills = document.querySelectorAll('.bar-fill[data-w], .bench-fill[data-w]');
  if (!fills.length) return;

  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        const el = e.target;
        el.style.width = el.dataset.w;
        io.unobserve(el);
      }
    });
  }, { threshold: 0.3 });

  fills.forEach(f => io.observe(f));
})();

// ─── Fade-in on Scroll ───────────────────────────────────────
(function () {
  const style = document.createElement('style');
  style.textContent = `
    .fade-in { opacity: 0; transform: translateY(24px); transition: opacity .55s ease, transform .55s ease; }
    .fade-in.visible { opacity: 1; transform: none; }
  `;
  document.head.appendChild(style);

  document.querySelectorAll('.card, .feature-row, .compare-block, .gpu-card, .tl-item, .stat-item, .bench-section, .vs-split, .vs-feature-card, .verdict-box').forEach(el => {
    el.classList.add('fade-in');
  });

  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); }
    });
  }, { threshold: 0.12 });

  document.querySelectorAll('.fade-in').forEach(el => io.observe(el));
})();

// ─── Active Nav Link ─────────────────────────────────────────
(function () {
  const page = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href');
    if (href === page || (page === '' && href === 'index.html')) {
      a.classList.add('active');
    }
  });
})();

// ─── Smooth stat counter ─────────────────────────────────────
(function () {
  function animateCount(el) {
    const target = parseFloat(el.dataset.count);
    const suffix = el.dataset.suffix || '';
    const duration = 1400;
    const start = performance.now();
    const isFloat = String(target).includes('.');

    function step(now) {
      const p = Math.min((now - start) / duration, 1);
      const ease = 1 - Math.pow(1 - p, 3);
      const val = target * ease;
      el.textContent = (isFloat ? val.toFixed(1) : Math.round(val)) + suffix;
      if (p < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }

  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        animateCount(e.target);
        io.unobserve(e.target);
      }
    });
  }, { threshold: 0.5 });

  document.querySelectorAll('.val[data-count]').forEach(el => io.observe(el));
})();
