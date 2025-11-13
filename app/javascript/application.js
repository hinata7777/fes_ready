// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").catch((error) => {
      console.error("Service worker registration failed:", error)
    })
  })
}
