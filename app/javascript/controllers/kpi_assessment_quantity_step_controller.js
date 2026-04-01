import { Controller } from "@hotwired/stimulus"

// Handles staff selection autofill and quantity section visibility for KPI step-1.
export default class extends Controller {
  static targets = ["staffSelect", "positionField", "reviewedByField", "quantitySection", "infoBanner"]

  connect() {
    this.staffChanged()
  }

  closeInfoBanner() {
    if (!this.hasInfoBannerTarget) return

    this.infoBannerTarget.remove()
  }

  staffChanged() {
    const option = this.staffSelectTarget.selectedOptions[0]

    if (!option || !option.value) {
      this.positionFieldTarget.value = ""
      this.reviewedByFieldTarget.value = ""
      this.quantitySectionTarget.classList.add("d-none")
      this.toggleScoreInputs(true)
      this.resetScoreOutputs()
      return
    }

    this.positionFieldTarget.value = option.dataset.position || ""
    this.reviewedByFieldTarget.value = option.dataset.reviewer || ""
    this.quantitySectionTarget.classList.remove("d-none")
    this.toggleScoreInputs(false)
    this.updateQuantityTotal()
  }

  toggleScoreInputs(disabled) {
    this.scoreInputs().forEach((input) => {
      input.disabled = disabled
    })
  }

  resetScoreOutputs() {
    const sectionScore = this.quantitySectionTarget.querySelector('[data-kpi-quantity-form-target="sectionScore"]')
    if (sectionScore) {
      sectionScore.textContent = "-%"
    }

    const overallOutput = this.quantitySectionTarget.querySelector(".kpi-overall-score span")
    if (overallOutput) {
      overallOutput.textContent = "---"
    }
  }

  updateQuantityTotal() {
    const sectionScore = this.quantitySectionTarget.querySelector('[data-kpi-quantity-form-target="sectionScore"]')
    const overallOutput = this.quantitySectionTarget.querySelector(".kpi-overall-score span")

    if (!sectionScore || !overallOutput) return

    const total = this.scoreInputs().reduce((sum, input) => {
      const actual = this.toNumber(input.value)
      const maxInput = this.toNumber(input.dataset.maxInput)
      const weight = this.toNumber(input.dataset.weight)
      if (maxInput <= 0) return sum

      return sum + ((actual / maxInput) * weight)
    }, 0)

    sectionScore.textContent = `${total.toFixed(2)}%`
    overallOutput.textContent = total.toFixed(2)
  }

  scoreInputs() {
    return Array.from(this.quantitySectionTarget.querySelectorAll("input.score-input"))
  }

  toNumber(value) {
    const numberValue = Number.parseFloat(String(value || "").trim())
    return Number.isNaN(numberValue) ? 0 : numberValue
  }
}
