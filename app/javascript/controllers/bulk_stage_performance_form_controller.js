import { Controller } from "@hotwired/stimulus"

// フェス日程変更に合わせて開始/終了の日時とステージ選択を揃える
export default class extends Controller {
  static targets = ["festivalDaySelect", "timeField", "stageSelect"]
  static values = {
    festivalDayDates: Object,
    festivalDayFestivalMap: Object,
    stages: Object,
    defaultTime: { type: String, default: "00:00" },
    minuteStep: { type: Number, default: 5 }
  }

  connect() {
    this.applyMinuteStep()
    this.syncStageOptions()
  }

  onFestivalDayChange() {
    const dayId = this.festivalDaySelectTarget.value
    const date = this.festivalDayDatesValue[dayId]
    if (date) {
      this.timeFieldTargets.forEach((input) => {
        const timePart = this.extractTime(input.value) || input.dataset.defaultTime || this.defaultTimeValue
        input.value = `${date}T${timePart}`
        this.normalizeTimeForInput(input)
      })
    }
    this.syncStageOptions()
  }

  normalizeTime(event) {
    this.normalizeTimeForInput(event.target)
  }

  applyMinuteStep() {
    const stepSeconds = this.minuteStepValue * 60
    this.timeFieldTargets.forEach((input) => {
      input.step = stepSeconds
      this.normalizeTimeForInput(input)
    })
  }

  syncStageOptions() {
    const dayId = this.festivalDaySelectTarget.value
    const festivalId = this.festivalDayFestivalMapValue[dayId]
    const stageOptions = this.stagesValue[festivalId] || []
    const current = this.stageSelectTarget.value

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = "(未定)"

    this.stageSelectTarget.innerHTML = ""
    this.stageSelectTarget.appendChild(placeholder)

    stageOptions.forEach(({ id, name }) => {
      const opt = document.createElement("option")
      opt.value = String(id)
      opt.textContent = name
      this.stageSelectTarget.appendChild(opt)
    })

    const exists = stageOptions.some(({ id }) => String(id) === String(current))
    this.stageSelectTarget.value = exists ? current : ""
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

    const normalizedMinute = Math.floor(minute / this.minuteStepValue) * this.minuteStepValue
    if (normalizedMinute === minute) return

    const normalizedTime = `${this.pad(hour)}:${this.pad(normalizedMinute)}`
    input.value = `${date}T${normalizedTime}`
  }

  extractTime(value) {
    if (!value) return null
    const match = value.match(/T(\d{2}:\d{2})/)
    return match ? match[1] : null
  }

  pad(value) {
    return String(value).padStart(2, "0")
  }
}
