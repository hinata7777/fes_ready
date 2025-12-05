import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "name", "spotifyId", "artistSelect"]

  connect() {
    this.minLen = 1
    this.abortController = null
    this.tracks = []
    this.clearResults()
    this._onClickOutside = (e) => {
      if (!this.element.contains(e.target)) this.clearResults()
    }
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    if (this.abortController) this.abortController.abort()
    document.removeEventListener("click", this._onClickOutside)
  }

  onSearch(event) {
    event?.preventDefault()
    const q = this.queryTarget.value.trim()
    if (q.length < this.minLen) return this.clearResults()
    this.search(q)
  }

  async search(q) {
    try {
      if (this.abortController) this.abortController.abort()
      this.abortController = new AbortController()

      this.resultsTarget.innerHTML = `<div class="px-3 py-2 text-sm text-slate-500">検索中...</div>`
      this.resultsTarget.classList.remove("hidden")

      const url = `/admin/spotify/search_tracks?q=${encodeURIComponent(q)}&market=JP`
      const res = await fetch(url, {
        headers: { "Accept": "application/json" },
        signal: this.abortController.signal
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()
      this.tracks = data.tracks || []
      this.renderResults(this.tracks)
    } catch (e) {
      if (e.name === "AbortError") return
      this.resultsTarget.innerHTML = `<div class="px-3 py-2 text-sm text-slate-500">取得に失敗しました</div>`
      this.resultsTarget.classList.remove("hidden")
    }
  }

  renderResults(tracks) {
    if (!tracks.length) return this.clearResults()

    this.resultsTarget.setAttribute("role", "listbox")
    this.resultsTarget.innerHTML = tracks.map((t, idx) => {
      const img = t.image_url
        ? `<img src="${t.image_url}" class="h-10 w-10 object-cover rounded mr-3" alt="">`
        : `<div class="h-10 w-10 bg-slate-200 rounded mr-3"></div>`
      const artists = (t.artists || []).map((a) => this.escape(a.name)).join(", ")
      const album = this.escape(t.album_name)
      return `
        <button type="button" role="option" aria-selected="false"
                data-index="${idx}"
                class="w-full flex items-center px-3 py-2 hover:bg-slate-50 focus:bg-slate-50">
          ${img}
          <div class="text-left">
            <div class="font-semibold">${this.escape(t.name)}</div>
            <div class="text-xs text-slate-500">${artists}</div>
            ${album ? `<div class="text-xs text-slate-400">${album}</div>` : ""}
          </div>
          <span class="ml-auto text-xs text-slate-400">${t.id || ""}</span>
        </button>
      `
    }).join("")
    this.resultsTarget.classList.remove("hidden")

    this.resultsTarget.querySelectorAll("button[role=option]").forEach(btn => {
      btn.addEventListener("click", (ev) => {
        const index = Number(ev.currentTarget.dataset.index)
        this.applySelection(tracks[index])
      }, { once: true })
    })
  }

  applySelection(track) {
    if (!track) return
    if (this.nameTarget.value.trim() === "" && track.name) {
      this.nameTarget.value = track.name
    }
    if (track.id) this.spotifyIdTarget.value = track.id

    // アーティスト自動選択（最初のアーティストのSpotify IDで一致する option を探す）
    const firstArtist = (track.artists || [])[0]
    if (firstArtist && this.hasArtistSelectTarget) {
      const option = Array.from(this.artistSelectTarget.options).find(
        (opt) => opt.dataset.spotifyId && opt.dataset.spotifyId === firstArtist.id
      )
      if (option) {
        this.artistSelectTarget.value = option.value
        this.artistSelectTarget.dispatchEvent(new Event("change"))
      }
    }

    this.clearResults()
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.classList.add("hidden")
  }

  escape(s) {
    return (s || "").replace(/[&<>"']/g, m => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    }[m]))
  }
}
