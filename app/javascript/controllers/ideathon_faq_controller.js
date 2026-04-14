import { Controller } from "@hotwired/stimulus"

// Controls FAQ accordion functionality
export default class extends Controller {
  static targets = ["button", "content"]
  
  connect() {
    // Initialize all FAQ items as closed
    this.contentTargets.forEach(content => {
      content.classList.add("hidden")
    })
  }
  
  toggle(event) {
    const button = event.currentTarget
    const content = button.nextElementSibling
    const icon = button.querySelector("svg")
    
    // Close all other items
    this.contentTargets.forEach((c, index) => {
      if (c !== content) {
        c.classList.add("hidden")
        const otherIcon = this.buttonTargets[index]?.querySelector("svg")
        if (otherIcon) {
          otherIcon.classList.remove("rotate-180")
        }
      }
    })
    
    // Toggle current item
    const isHidden = content.classList.contains("hidden")
    
    if (isHidden) {
      content.classList.remove("hidden")
      content.style.maxHeight = content.scrollHeight + "px"
      icon?.classList.add("rotate-180")
    } else {
      content.classList.add("hidden")
      content.style.maxHeight = "0"
      icon?.classList.remove("rotate-180")
    }
  }
}
