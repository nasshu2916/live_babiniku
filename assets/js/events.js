export function eventHandlers() {
  window.addEventListener("lb:clipcopy", (event) => {
    if ("clipboard" in navigator) {
      const text = event.target.textContent
      navigator.clipboard.writeText(text)
    } else {
      alert("clipboard write failed")
    }
  })
}
