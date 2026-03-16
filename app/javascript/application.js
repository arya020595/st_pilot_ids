// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// Import Popper.js first (required for Bootstrap dropdowns, popovers, tooltips)
import "@popperjs/core";

// Bootstrap JavaScript - auto-initializes data-bs-* attributes
import "bootstrap";

// Capture the modal trigger link so the modal controller can read data-modal-size
document.addEventListener("click", (event) => {
  const link = event.target.closest("a[data-turbo-frame][data-modal-size]");
  if (link) {
    window.lastModalTrigger = link;
  }
});
