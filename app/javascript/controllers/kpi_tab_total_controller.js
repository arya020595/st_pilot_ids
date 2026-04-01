import { Controller } from "@hotwired/stimulus"

// Switches the single header overall total based on selected KPI tab.
export default class extends Controller {
  static targets = ["totalValue"]
  static values = {
    quality: String,
    quantity: String
  }

  connect() {
    this.showQuantity()
  }

  showQuality() {
    this.totalValueTarget.textContent = this.qualityValue || "0"
  }

  showQuantity() {
    this.totalValueTarget.textContent = this.quantityValue || "0"
  }
}
