// Vercel Web Analytics
// This script initializes Vercel Web Analytics for the website
(function() {
  // Initialize the queue
  window.va = window.va || function() {
    (window.vaq = window.vaq || []).push(arguments);
  };

  // Create and inject the script
  var script = document.createElement('script');
  script.src = '/_vercel/insights/script.js';
  script.defer = true;
  script.dataset.sdkn = '@vercel/analytics';
  script.dataset.sdkv = '2.0.1';
  
  script.onerror = function() {
    console.log('[Vercel Web Analytics] Failed to load script. Please check if any content blockers are enabled and try again.');
  };
  
  document.head.appendChild(script);
})();
