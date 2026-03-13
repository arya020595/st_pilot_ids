import { Controller } from "@hotwired/stimulus";

// Modal Controller - manages Bootstrap modal lifecycle
// Usage: data-controller="modal"
// Content loaded via turbo-frame with turbo:frame-load->modal#show action
export default class extends Controller {
  static values = {
    frameId: { type: String, default: "modal" },
    focusSelector: {
      type: String,
      default: "input:not([type=hidden]), select, textarea",
    },
  };

  static VALID_SIZES = [
    "modal-sm",
    "modal-md",
    "modal-lg",
    "modal-xl",
    "modal-fullscreen",
  ];

  connect() {
    this.BootstrapModal = (window.bootstrap && window.bootstrap.Modal) || null;

    if (!this.BootstrapModal) {
      console.warn(
        "Bootstrap Modal not found on window.bootstrap. Ensure bootstrap is imported in application.js",
      );
    }

    this._clearHandler = this.clearFrame.bind(this);
    this._submitHandler = this.formSubmitted.bind(this);

    const backdrop = this.element.dataset.bsBackdrop || "static";
    const keyboard = this.element.dataset.bsKeyboard === "true";

    if (this.BootstrapModal) {
      this.modal = new this.BootstrapModal(this.element, {
        backdrop: backdrop,
        keyboard: keyboard,
      });
    }

    this.element.addEventListener("hidden.bs.modal", this._clearHandler);
    this.element.addEventListener("turbo:submit-end", this._submitHandler);
    this.element.addEventListener("turbo:before-cache", () => {
      if (this.modal) this.modal.hide();
    });
    this.element.addEventListener("shown.bs.modal", () =>
      this.focusFirstField(),
    );
  }

  show(event) {
    if (!this.modal && this.BootstrapModal) {
      const backdrop = this.element.dataset.bsBackdrop || "static";
      const keyboard = this.element.dataset.bsKeyboard === "true";

      this.modal = new this.BootstrapModal(this.element, {
        backdrop: backdrop,
        keyboard: keyboard,
      });
    }

    this.applyDynamicSize();
    this.modal.show();
  }

  applyDynamicSize() {
    const modalDialog = this.element.querySelector(".modal-dialog");
    if (!modalDialog) return;

    this.constructor.VALID_SIZES.forEach((size) => {
      modalDialog.classList.remove(size);
    });

    const trigger = window.lastModalTrigger;

    if (trigger?.dataset?.modalSize) {
      const requestedSize = trigger.dataset.modalSize;
      if (this.constructor.VALID_SIZES.includes(requestedSize)) {
        modalDialog.classList.add(requestedSize);
      }
    }
  }

  formSubmitted(event) {
    const { success } = event.detail;
    if (success) {
      this.modal.hide();
    }
  }

  clearFrame() {
    const frame = this.element.querySelector(
      `turbo-frame#${this.frameIdValue}`,
    );
    if (frame) frame.innerHTML = "";
  }

  focusFirstField() {
    const frame = this.element.querySelector(
      `turbo-frame#${this.frameIdValue}`,
    );
    if (!frame) return;
    const el = frame.querySelector(this.focusSelectorValue);
    if (el && typeof el.focus === "function") el.focus();
  }

  disconnect() {
    this.element.removeEventListener("hidden.bs.modal", this._clearHandler);
    this.element.removeEventListener("turbo:submit-end", this._submitHandler);

    if (this.modal) this.modal.dispose();
  }
}
