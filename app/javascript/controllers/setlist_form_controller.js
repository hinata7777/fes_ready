import { Controller } from "@hotwired/stimulus"

// セットリストフォーム
// - アーティスト選択 → そのアーティストの出演枠（stage_performance）を選択
// - 行ごとの曲プルダウンは、選択済みアーティストの曲で絞り込む
export default class extends Controller {
  static targets = ["artist", "stagePerformance", "songSelect", "showAllToggle"]
  static values = {
    performances: Object, // { artist_id: [ {id, festival_day, stage, starts_at}, ... ] }
    songs: Object,        // { artist_id: [ {id, name}, ... ] }
    performancesUrl: String,
    songsUrl: String,
    allSongsUrl: String
  }

  connect() {
    this.performancesCache = { ...this.performancesValue }
    this.songsCache = { ...this.songsValue }
    this.allSongsCache = null
    this.pendingAllSongs = null
    this.onArtistChange()
  }

  async onArtistChange() {
    const artistId = this.artistTarget.value
    await this.ensureArtistData(artistId)
    this.populatePerformances(artistId)
    this.populateSongs(artistId)
  }

  async onShowAllToggle(event) {
    const selectId = event.target.dataset.selectId
    const select = document.getElementById(selectId)
    if (!select) return
    select.dataset.showAll = event.target.checked
    if (event.target.checked) {
      await this.ensureAllSongs()
    }
    this.populateSongSelect(select, this.artistTarget.value)
  }

  populatePerformances(artistId) {
    const performances = this.performancesCache[artistId] || []
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
    const songs = showAll ? (this.allSongsCache || []) : (this.songsCache[artistId] || [])
    const current = select.dataset.selected || select.value
    const currentLabel = current
      ? select.querySelector(`option[value="${current}"]`)?.textContent
      : null

    select.innerHTML = ""

    const blank = document.createElement("option")
    blank.value = ""
    blank.textContent = "曲を選択"
    select.appendChild(blank)

    let hasCurrent = false
    ;[...songs].sort((a, b) => a.name.localeCompare(b.name, "ja")).forEach((s) => {
      const opt = document.createElement("option")
      opt.value = s.id
      opt.textContent = showAll && s.artist_name ? `${s.name} / ${s.artist_name}` : s.name
      if (current && String(current) === String(s.id)) hasCurrent = true
      select.appendChild(opt)
    })

    if (current) {
      if (hasCurrent) {
        select.value = current
      } else {
        const opt = document.createElement("option")
        opt.value = current
        opt.textContent = currentLabel || "選択済み（他アーティスト曲）"
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

  async ensureArtistData(artistId) {
    if (!artistId) return

    const tasks = []
    if (!this.performancesCache[artistId]) {
      tasks.push(this.fetchPerformances(artistId))
    }
    if (!this.songsCache[artistId]) {
      tasks.push(this.fetchSongs(artistId))
    }

    if (tasks.length > 0) {
      await Promise.all(tasks)
    }
  }

  async ensureAllSongs() {
    if (this.allSongsCache) return
    if (this.pendingAllSongs) return this.pendingAllSongs
    if (!this.hasAllSongsUrlValue || !this.allSongsUrlValue) return

    this.pendingAllSongs = fetch(this.allSongsUrlValue, {
      headers: { "Accept": "application/json" }
    })
      .then((res) => (res.ok ? res.json() : { songs: [] }))
      .then((data) => {
        this.allSongsCache = Array.isArray(data.songs) ? data.songs : []
        return this.allSongsCache
      })
      .catch(() => {
        this.allSongsCache = []
        return this.allSongsCache
      })
      .finally(() => {
        this.pendingAllSongs = null
      })

    return this.pendingAllSongs
  }

  async fetchSongs(artistId) {
    if (!this.hasSongsUrlValue || !this.songsUrlValue) return

    const url = `${this.songsUrlValue}?artist_id=${encodeURIComponent(artistId)}`
    try {
      const res = await fetch(url, { headers: { "Accept": "application/json" } })
      if (!res.ok) return
      const data = await res.json()
      this.songsCache[artistId] = Array.isArray(data.songs) ? data.songs : []
    } catch {
      this.songsCache[artistId] = []
    }
  }

  async fetchPerformances(artistId) {
    if (!this.hasPerformancesUrlValue || !this.performancesUrlValue) return

    const url = `${this.performancesUrlValue}?artist_id=${encodeURIComponent(artistId)}`
    try {
      const res = await fetch(url, { headers: { "Accept": "application/json" } })
      if (!res.ok) return
      const data = await res.json()
      this.performancesCache[artistId] = Array.isArray(data.performances) ? data.performances : []
    } catch {
      this.performancesCache[artistId] = []
    }
  }
}
