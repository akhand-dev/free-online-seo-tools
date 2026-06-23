// Vercel Speed Insights
// This script initializes Vercel Speed Insights for the website
(function() {
  // Initialize the queue
  window.si = window.si || function() {
    (window.siq = window.siq || []).push(arguments);
  };

  // Create and inject the script
  var script = document.createElement('script');
  script.src = '/_vercel/speed-insights/script.js';
  script.defer = true;
  script.dataset.sdkn = '@vercel/speed-insights';
  script.dataset.sdkv = '1.3.1';
  
  script.onerror = function() {
    console.log('[Vercel Speed Insights] Failed to load script. Please check if any content blockers are enabled and try again.');
  };
  
  document.head.appendChild(script);
})();
