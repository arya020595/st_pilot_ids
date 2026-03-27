import { Controller } from "@hotwired/stimulus"

// Quantity step uses direct total without additional section weighting.
export default class extends Controller {
  static targets = ["sectionScore"]

  connect() {
    this.updateTotal()
  }

  scoreChanged(event) {
    const input = event.target
    if (!(input instanceof HTMLInputElement) || !input.classList.contains("score-input")) return

    const min = this.toNumber(input.min)
    const max = this.toNumber(input.max)
    const current = this.toNumber(input.value)

    if (input.value !== "") {
      if (current < min) input.value = String(min)
      if (current > max) input.value = String(max)
    }

    this.updateTotal()
  }

  updateTotal() {
    const total = this.scoreInputs().reduce((sum, input) => sum + this.toNumber(input.value), 0)

    if (this.hasSectionScoreTarget) {
      this.sectionScoreTarget.textContent = `${total.toFixed(2)}%`
    }

    const output = this.element.querySelector(".kpi-overall-score span")
    if (output) {
      output.textContent = total.toFixed(2)
    }
  }

  scoreInputs() {
    return Array.from(this.element.querySelectorAll("input.score-input"))
  }

  toNumber(value) {
    const numberValue = Number.parseFloat(String(value || "").trim())
    return Number.isNaN(numberValue) ? 0 : numberValue
  }
}
