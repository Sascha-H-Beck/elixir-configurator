// Synchronously apply saved theme before first paint to prevent FOUC
;(function () {
  var t = localStorage.getItem("phx:theme")
  if (t && t !== "system") {
    document.documentElement.setAttribute("data-theme", t)
    document.documentElement.setAttribute("data-theme-mode", t)
  } else {
    var dark = window.matchMedia("(prefers-color-scheme: dark)").matches
    document.documentElement.setAttribute("data-theme", dark ? "dark" : "light")
    document.documentElement.setAttribute("data-theme-mode", "system")
  }
})()
