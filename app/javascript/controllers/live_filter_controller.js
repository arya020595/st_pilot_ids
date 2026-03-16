import { Controller } from "@hotwired/stimulus";

// Auto-submits filter form after a short pause while typing.
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 350 },
  };

  connect() {
    this.timeout = null;
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout);
  }

  queue() {
    if (this.timeout) clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, this.delayValue);
  }
}
