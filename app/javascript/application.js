// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.config.forms.confirm = (message) => {
  return new Promise((resolve) => {
    const modal   = document.getElementById("turbo-confirm-modal")
    const msg     = document.getElementById("turbo-confirm-message")
    const okBtn   = document.getElementById("turbo-confirm-ok")
    const cancelBtn = document.getElementById("turbo-confirm-cancel")

    // Some layouts (e.g., dashboard/application) do not render the custom modal.
    // Fall back to browser confirm instead of throwing on null nodes.
    if (!modal || !msg || !okBtn || !cancelBtn) {
      resolve(window.confirm(message))
      return
    }

    msg.textContent = message
    modal.classList.remove("hidden")
    modal.classList.add("flex")

    const close = (result) => {
      modal.classList.add("hidden")
      modal.classList.remove("flex")
      okBtn.removeEventListener("click", onOk)
      cancelBtn.removeEventListener("click", onCancel)
      modal.removeEventListener("click", onBackdrop)
      resolve(result)
    }

    const onOk       = () => close(true)
    const onCancel   = () => close(false)
    const onBackdrop = (e) => { if (e.target === modal) close(false) }

    okBtn.addEventListener("click", onOk)
    cancelBtn.addEventListener("click", onCancel)
    modal.addEventListener("click", onBackdrop)
  })
}
