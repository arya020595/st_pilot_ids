import { Controller } from "@hotwired/stimulus"

// Handles staff selection autofill and quality section visibility for the KPI step-1 form.
export default class extends Controller {
  static targets = ["staffSelect", "positionField", "reviewedByField", "qualitySection", "infoBanner"]

  researchAssistantAllowedFields = new Set([
    "data_collection",
    "data_entry_and_cleaning",
    "communication_skill",
    "collaboration_teamwork",
    "attention_details",
    "ideas_platform",
    "any_social_media_platform",
    "ids_watch_column",
    "others"
  ])

  researchAssistantFullScores = {
    data_collection: 50,
    data_entry_and_cleaning: 50,
    communication_skill: 30,
    collaboration_teamwork: 30,
    attention_details: 40
  }

  researchAssistantSectionWeights = {
    A: "80%",
    D: "10%",
    E: "10%"
  }

  researchOfficerComponentCFields = new Set([
    "writing_skill",
    "presentation_skill",
    "computer_skill",
    "management_skill",
    "statistical_knowledge"
  ])

  researchAssociateFullScores = {
    proposal_preparation: 15,
    proposal_presentation: 15,
    data_collection: 5,
    data_entry_and_cleaning: 0,
    report_writing: 25,
    analysis_of_data: 10,
    presentation_of_findings: 30,
    writing_skill: 20,
    presentation_skill: 20,
    computer_skill: 20,
    management_skill: 20,
    statistical_knowledge: 20
  }

  researchAssociateSectionWeights = {
    A: "60%",
    C: "20%"
  }

  researchAssociateLockedFields = new Set(["data_entry_and_cleaning"])

  seniorResearchAssociateFullScores = {
    proposal_preparation: 5,
    proposal_presentation: 5,
    data_collection: 0,
    data_entry_and_cleaning: 0,
    report_writing: 20,
    analysis_of_data: 10,
    presentation_of_findings: 60,
    writing_skill: 20,
    presentation_skill: 20,
    computer_skill: 20,
    management_skill: 20,
    statistical_knowledge: 20,
    leadership: 30,
    attention_details: 10
  }

  seniorResearchAssociateSectionWeights = {
    A: "50%",
    B: "5%",
    C: "25%",
    D: "10%",
    E: "10%"
  }

  seniorResearchAssociateLockedFields = new Set(["data_collection", "data_entry_and_cleaning"])

  connect() {
    this.boundInputHandler = this.handleScoreInput.bind(this)
    this.qualitySectionTarget.addEventListener("input", this.boundInputHandler)
    this.staffChanged()
  }

  disconnect() {
    if (this.boundInputHandler) {
      this.qualitySectionTarget.removeEventListener("input", this.boundInputHandler)
    }
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
      this.qualitySectionTarget.classList.add("d-none")
      this.enableAllQualityInputs()
      this.resetScoreOutputs()
      return
    }

    const position = option.dataset.position || ""
    this.positionFieldTarget.value = position
    this.reviewedByFieldTarget.value = option.dataset.reviewer || ""
    this.qualitySectionTarget.classList.remove("d-none")
    this.applyPositionRules(position)
    this.updateWeightedScores()
  }

  applyPositionRules(position) {
    const normalizedPosition = position.trim().toLowerCase()

    if (normalizedPosition === "research assistant") {
      this.applyResearchAssistantScoreDisplay()
      this.applyResearchAssistantRules()
      this.updateWeightedScores()
      return
    }

    if (normalizedPosition === "research associate") {
      this.restoreDefaultScoreDisplay()
      this.enableAllQualityInputs()
      this.applyResearchAssociateScoreDisplay()
      this.applyResearchAssociateRules()
      this.updateWeightedScores()
      return
    }

    if (normalizedPosition === "senior research associate") {
      this.restoreDefaultScoreDisplay()
      this.enableAllQualityInputs()
      this.applySeniorResearchAssociateScoreDisplay()
      this.applySeniorResearchAssociateRules()
      this.updateWeightedScores()
      return
    }

    if (normalizedPosition === "research officer") {
      this.restoreDefaultScoreDisplay()
      this.applyResearchOfficerScoreDisplay()
      this.enableAllQualityInputs()
      this.updateWeightedScores()
      return
    }

    this.restoreDefaultScoreDisplay()
    this.enableAllQualityInputs()
    this.updateWeightedScores()
  }

  applyResearchOfficerScoreDisplay() {
    this.qualityInputs().forEach((input) => {
      if (!this.researchOfficerComponentCFields.has(input.name)) return

      const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
      if (!scoreCell) return

      scoreCell.textContent = "20%"
      input.max = "20"
    })

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      if (section.dataset.sectionCode !== "C") return

      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionWeightCell) return

      sectionWeightCell.textContent = "10%"
    })
  }

  applyResearchAssociateScoreDisplay() {
    this.qualityInputs().forEach((input) => {
      if (!Object.prototype.hasOwnProperty.call(this.researchAssociateFullScores, input.name)) return

      const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
      if (!scoreCell) return

      const score = this.researchAssociateFullScores[input.name]
      scoreCell.textContent = `${score}%`
      input.max = String(score)
    })

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      const code = section.dataset.sectionCode
      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionWeightCell) return

      if (Object.prototype.hasOwnProperty.call(this.researchAssociateSectionWeights, code)) {
        sectionWeightCell.textContent = this.researchAssociateSectionWeights[code]
      }
    })
  }

  applyResearchAssociateRules() {
    this.qualityInputs().forEach((input) => {
      if (!this.researchAssociateLockedFields.has(input.name)) return

      input.value = ""
      input.readOnly = true
      input.required = false
      input.tabIndex = -1
      input.removeAttribute("placeholder")
      input.classList.add("is-disabled-by-position")
      input.dataset.lockedByPosition = "true"
    })
  }

  applySeniorResearchAssociateScoreDisplay() {
    this.qualityInputs().forEach((input) => {
      if (!Object.prototype.hasOwnProperty.call(this.seniorResearchAssociateFullScores, input.name)) return

      const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
      if (!scoreCell) return

      const score = this.seniorResearchAssociateFullScores[input.name]
      scoreCell.textContent = `${score}%`
      input.max = String(score)
    })

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      const code = section.dataset.sectionCode
      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionWeightCell) return

      if (Object.prototype.hasOwnProperty.call(this.seniorResearchAssociateSectionWeights, code)) {
        sectionWeightCell.textContent = this.seniorResearchAssociateSectionWeights[code]
      }
    })
  }

  applySeniorResearchAssociateRules() {
    this.qualityInputs().forEach((input) => {
      if (!this.seniorResearchAssociateLockedFields.has(input.name)) return

      input.value = ""
      input.readOnly = true
      input.required = false
      input.tabIndex = -1
      input.removeAttribute("placeholder")
      input.classList.add("is-disabled-by-position")
      input.dataset.lockedByPosition = "true"
    })
  }

  applyResearchAssistantRules() {
    this.qualityInputs().forEach((input) => {
      const fieldName = input.name
      const isAllowed = this.researchAssistantAllowedFields.has(fieldName)

      if (isAllowed) {
        input.readOnly = false
        input.required = true
        input.removeAttribute("tabindex")
        input.setAttribute("placeholder", input.dataset.defaultPlaceholder || "Enter Actual Score")
        input.classList.remove("is-disabled-by-position")
        input.dataset.lockedByPosition = "false"
        return
      }

      input.value = ""
      input.readOnly = true
      input.required = false
      input.tabIndex = -1
      input.removeAttribute("placeholder")
      input.classList.add("is-disabled-by-position")
      input.dataset.lockedByPosition = "true"
    })
  }

  enableAllQualityInputs() {
    this.qualityInputs().forEach((input) => {
      if (input.dataset.lockedByPosition === "true") {
        input.value = ""
      }

      input.readOnly = false
      input.required = true
      input.removeAttribute("tabindex")
      input.setAttribute("placeholder", input.dataset.defaultPlaceholder || "Enter Actual Score")
      input.classList.remove("is-disabled-by-position")
      input.dataset.lockedByPosition = "false"
    })
  }

  applyResearchAssistantScoreDisplay() {
    this.qualityInputs().forEach((input) => {
      const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
      if (!scoreCell) return

      const fieldName = input.name
      const isAllowed = this.researchAssistantAllowedFields.has(fieldName)
      if (Object.prototype.hasOwnProperty.call(this.researchAssistantFullScores, fieldName)) {
        scoreCell.textContent = `${this.researchAssistantFullScores[fieldName]}%`
        input.max = String(this.researchAssistantFullScores[fieldName])
      } else if (isAllowed) {
        const defaultScore = scoreCell.dataset.defaultFullScore || "0%"
        scoreCell.textContent = defaultScore
        input.max = this.parsePercentValue(defaultScore)
      } else {
        scoreCell.textContent = "0%"
        input.max = "0"
      }
    })

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      const code = section.dataset.sectionCode
      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionWeightCell) return

      sectionWeightCell.textContent = this.researchAssistantSectionWeights[code] || "0%"
    })
  }

  restoreDefaultScoreDisplay() {
    this.qualityInputs().forEach((input) => {
      const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
      if (!scoreCell) return

      const defaultScore = scoreCell.dataset.defaultFullScore || "0%"
      scoreCell.textContent = defaultScore
      input.max = this.parsePercentValue(defaultScore)
    })

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionWeightCell) return

      sectionWeightCell.textContent = sectionWeightCell.dataset.defaultSectionWeight || "0%"
    })
  }

  handleScoreInput(event) {
    const input = event.target
    if (!(input instanceof HTMLInputElement) || !input.classList.contains("score-input")) return

    if (input.readOnly || input.dataset.lockedByPosition === "true") {
      input.value = ""
      this.updateWeightedScores()
      return
    }

    const max = this.toNumber(input.max)
    const min = this.toNumber(input.min)
    const current = this.toNumber(input.value)

    if (input.value !== "") {
      if (!Number.isNaN(min) && current < min) {
        input.value = String(min)
      }

      if (!Number.isNaN(max) && current > max) {
        input.value = String(max)
      }
    }

    this.updateWeightedScores()
  }

  updateWeightedScores() {
    let overall = 0

    this.qualitySectionTarget.querySelectorAll(".kpi-section-block").forEach((section) => {
      const sectionScoreCell = section.querySelector(".section-score-cell")
      const sectionWeightCell = section.querySelector(".section-weight-cell")
      if (!sectionScoreCell || !sectionWeightCell) return

      const sectionWeight = this.parsePercentValue(sectionWeightCell.textContent)
      let achieved = 0
      let full = 0

      section.querySelectorAll("input.score-input").forEach((input) => {
        const scoreCell = input.closest("tr")?.querySelector(".full-score-cell")
        const fullScore = this.parsePercentValue(scoreCell?.textContent || "0%")
        const actualScore = this.toNumber(input.value)

        achieved += Number.isNaN(actualScore) ? 0 : actualScore
        full += fullScore
      })

      const sectionRaw = full > 0 ? (achieved / full) * 100 : 0
      const weighted = sectionRaw * (sectionWeight / 100)
      overall += weighted

      sectionScoreCell.textContent = `${weighted.toFixed(2)}%`
    })

    this.overallScoreOutput().textContent = overall.toFixed(2)
  }

  resetScoreOutputs() {
    this.qualitySectionTarget.querySelectorAll(".section-score-cell").forEach((cell) => {
      cell.textContent = "-%"
    })

    this.overallScoreOutput().textContent = "---"
  }

  overallScoreOutput() {
    return this.qualitySectionTarget.querySelector(".kpi-overall-score span")
  }

  parsePercentValue(label) {
    const value = String(label || "").replace("%", "").trim()
    return this.toNumber(value)
  }

  toNumber(value) {
    const numberValue = Number.parseFloat(String(value || "").trim())
    return Number.isNaN(numberValue) ? 0 : numberValue
  }

  qualityInputs() {
    return this.qualitySectionTarget.querySelectorAll("input.score-input")
  }
}
