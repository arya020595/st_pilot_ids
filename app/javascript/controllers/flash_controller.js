import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="flash"
// Auto-dismisses flash messages after a specified delay
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 },
  };

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss();
    }, this.delayValue);
  }

  dismiss() {
    const Alert = window.bootstrap?.Alert;
    if (Alert) {
      const instance =
        Alert.getInstance?.(this.element) || new Alert(this.element);
      instance.close();
      return;
    }

    this.element.remove();
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}
