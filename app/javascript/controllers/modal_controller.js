import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";

// Connects to data-controller="modal"
export default class extends Controller {
  static values = { defaultSize: String };

  connect() {
    this.modal = new bootstrap.Modal(this.element);

    // Show modal when turbo frame content is loaded
    this.element.addEventListener("turbo:frame-load", () => {
      this.modal.show();
    });

    // Clear turbo frame content when modal is hidden
    this.element.addEventListener("hidden.bs.modal", () => {
      const frame = this.element.querySelector("turbo-frame");
      if (frame) {
        frame.innerHTML = "";
      }
    });
  }

  setSize(event) {
    const size = event.params?.modalSize || this.defaultSizeValue || "modal-lg";
    const dialog = this.element.querySelector(".modal-dialog");
    if (dialog) {
      dialog.className = `modal-dialog ${size} modal-dialog-centered`;
    }
  }

  disconnect() {
    if (this.modal) {
      this.modal.dispose();
    }
  }
}
