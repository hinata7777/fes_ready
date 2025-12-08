import { Controller } from "@hotwired/stimulus"

// セットリストフォーム
// - アーティスト選択 → そのアーティストの出演枠（stage_performance）を選択
// - 行ごとの曲プルダウンは、選択済みアーティストの曲で絞り込む
export default class extends Controller {
  static targets = ["artist", "stagePerformance", "songSelect", "showAllToggle"]
  static values = {
    performances: Object, // { artist_id: [ {id, festival_day, stage, starts_at}, ... ] }
    songs: Object,        // { artist_id: [ {id, name}, ... ] }
    allSongs: Array       // [ {id, name}, ... ]
  }

  connect() {
    this.onArtistChange()
  }

  onArtistChange() {
    const artistId = this.artistTarget.value
    this.populatePerformances(artistId)
    this.populateSongs(artistId)
  }

  onShowAllToggle(event) {
    const selectId = event.target.dataset.selectId
    const select = document.getElementById(selectId)
    if (!select) return
    select.dataset.showAll = event.target.checked
    this.populateSongSelect(select, this.artistTarget.value)
  }

  populatePerformances(artistId) {
    const performances = this.performancesValue[artistId] || []
    this.stagePerformanceTarget.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = "出演枠を選択"
    this.stagePerformanceTarget.appendChild(placeholder)

    performances.forEach((p) => {
      const opt = document.createElement("option")
      opt.value = p.id
      opt.textContent = this.formatPerformance(p)
      this.stagePerformanceTarget.appendChild(opt)
    })

    // 既存選択を維持
    const current = this.stagePerformanceTarget.dataset.selected
    if (current) {
      this.stagePerformanceTarget.value = current
    }
  }

  populateSongs(artistId) {
    this.songSelectTargets.forEach((select) => {
      this.populateSongSelect(select, artistId)
    })
  }

  populateSongSelect(select, artistId) {
    const showAll = select.dataset.showAll === "true"
    const songs = showAll ? this.allSongsValue : (this.songsValue[artistId] || [])
    const current = select.dataset.selected || select.value

    select.innerHTML = ""

    const blank = document.createElement("option")
    blank.value = ""
    blank.textContent = "曲を選択"
    select.appendChild(blank)

    let hasCurrent = false
    songs.forEach((s) => {
      const opt = document.createElement("option")
      opt.value = s.id
      opt.textContent = s.name
      if (current && String(current) === String(s.id)) hasCurrent = true
      select.appendChild(opt)
    })

    if (current) {
      if (hasCurrent) {
        select.value = current
      } else {
        const opt = document.createElement("option")
        opt.value = current
        opt.textContent = "選択済み（他アーティスト曲）"
        select.appendChild(opt)
        select.value = current
      }
    }
  }

  formatPerformance(p) {
    const fest = p.festival_name || ""
    const date = p.festival_date || ""
    const stage = p.stage_name || "(未定)"
    const startsAt = p.starts_at ? p.starts_at : ""
    return `${fest} / ${date} / ${stage} / ${startsAt}`
  }
}
