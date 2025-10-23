import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["festivalDaySelect", "stageSelect", "startsAt", "endsAt"]
  static values = {
    stages: Object,
    festivalDayMap: Object,
    festivalDayDates: Object,
    stagePlaceholder: String,
    minuteStep: Number
  }

  connect() {
    this.applyMinuteStep()
    this.updateStageOptions()
    this.syncDateInputs()
  }

  onFestivalDayChange() {
    this.updateStageOptions()
    this.syncDateInputs()
  }

  updateStageOptions() {
    if (!this.hasStageSelectTarget || !this.hasFestivalDaySelectTarget) return

    const stageSelect = this.stageSelectTarget
    const previousValue = stageSelect.value
    const festivalDayId = this.festivalDaySelectTarget.value

    this.resetStageOptions(stageSelect)

    if (!festivalDayId) return

    const festivalId = this.festivalDayMapValue[festivalDayId]
    if (!festivalId) return

    const festivalKey = String(festivalId)
    const stages = this.stagesValue[festivalKey] || []
    stages.forEach((stage) => {
      const option = document.createElement("option")
      option.value = String(stage.id)
      option.textContent = stage.name
      stageSelect.appendChild(option)
    })

    if (stages.some((stage) => String(stage.id) === previousValue)) {
      stageSelect.value = previousValue
    }
  }

  syncDateInputs() {
    if (!this.hasFestivalDaySelectTarget) return

    const festivalDayId = this.festivalDaySelectTarget.value
    if (!festivalDayId) return

    const isoDate = this.festivalDayDatesValue[festivalDayId]
    if (!isoDate) return

    if (this.hasStartsAtTarget) {
      this.syncDateForInput(this.startsAtTarget, isoDate)
    }
    if (this.hasEndsAtTarget) {
      this.syncDateForInput(this.endsAtTarget, isoDate)
    }
  }

  syncDateForInput(input, isoDate) {
    const defaultTime = input.dataset.defaultTime || "00:00"
    const currentValue = input.value

    if (currentValue) {
      const [currentDate, currentTime] = currentValue.split("T")
      const normalizedTime = (currentTime || defaultTime).slice(0, 5)
      if (currentDate !== isoDate) {
        input.value = `${isoDate}T${normalizedTime}`
      }
    } else {
      input.value = `${isoDate}T${defaultTime}`
    }

    this.normalizeTimeForInput(input)
  }

  resetStageOptions(stageSelect) {
    const placeholderText = this.stagePlaceholderValue || ""
    stageSelect.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = placeholderText
    stageSelect.appendChild(placeholder)
  }

  normalizeTime(event) {
    this.normalizeTimeForInput(event.target)
  }

  normalizeTimeForInput(input) {
    if (!input) return
    const value = input.value
    if (!value) return

    const [date, timePart] = value.split("T")
    if (!timePart) return

    const [time] = timePart.split(".")
    const segments = time.split(":")
    if (segments.length < 2) return

    const hour = parseInt(segments[0], 10)
    const minute = parseInt(segments[1], 10)
    if (Number.isNaN(hour) || Number.isNaN(minute)) return

    const normalizedMinute = this.normalizeMinuteValue(minute)
    if (normalizedMinute === minute) return

    const normalizedTime = `${this.pad(hour)}:${this.pad(normalizedMinute)}`
    input.value = `${date}T${normalizedTime}`
  }

  applyMinuteStep() {
    const stepSeconds = this.minuteStepInSeconds()
    if (this.hasStartsAtTarget) {
      this.startsAtTarget.step = stepSeconds
      this.normalizeTimeForInput(this.startsAtTarget)
    }
    if (this.hasEndsAtTarget) {
      this.endsAtTarget.step = stepSeconds
      this.normalizeTimeForInput(this.endsAtTarget)
    }
  }

  normalizeMinuteValue(minute) {
    const step = this.minuteStepAmount()
    if (step <= 0) return minute
    return Math.floor(minute / step) * step
  }

  minuteStepInSeconds() {
    return this.minuteStepAmount() * 60
  }

  minuteStepAmount() {
    return this.hasMinuteStepValue ? this.minuteStepValue : 5
  }

  pad(value) {
    return String(value).padStart(2, "0")
  }
}
