import { Controller } from "@hotwired/stimulus"

// Quantity step computes weighted contribution: (actual / max-input) * weight.
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
    const total = this.scoreInputs().reduce((sum, input) => {
      const actual = this.toNumber(input.value)
      const maxInput = this.toNumber(input.dataset.maxInput)
      const weight = this.toNumber(input.dataset.weight)
      if (maxInput <= 0) return sum

      return sum + ((actual / maxInput) * weight)
    }, 0)

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
