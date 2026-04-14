import { Controller } from "@hotwired/stimulus"

// Controls sticky navigation behavior and mobile menu with professional animations
export default class extends Controller {
  static targets = ["mobileMenu", "navbar", "menuButton", "menuIcon"]
  
  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll, { passive: true })
    this.isMobileMenuOpen = false
    this.lastScrollY = 0
  }
  
  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }
  
  handleScroll() {
    const scrollY = window.scrollY
    
    if (this.hasNavbarTarget) {
      // Add solid background and shadow after scrolling
      if (scrollY > 80) {
        this.navbarTarget.classList.add("glass-solid")
        this.navbarTarget.classList.remove("glass")
      } else {
        this.navbarTarget.classList.remove("glass-solid")
        this.navbarTarget.classList.add("glass")
      }
    }
    
    this.lastScrollY = scrollY
  }
  
  toggleMobile() {
    this.isMobileMenuOpen = !this.isMobileMenuOpen
    
    if (this.hasMobileMenuTarget) {
      if (this.isMobileMenuOpen) {
        // Open menu
        this.mobileMenuTarget.classList.remove("hidden", "mobile-menu-exit")
        this.mobileMenuTarget.classList.add("mobile-menu-enter")
        
        // Rotate hamburger icon to X
        if (this.hasMenuIconTarget) {
          this.menuIconTarget.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          `
        }
      } else {
        // Close menu
        this.mobileMenuTarget.classList.remove("mobile-menu-enter")
        this.mobileMenuTarget.classList.add("mobile-menu-exit")
        
        // Restore hamburger icon
        if (this.hasMenuIconTarget) {
          this.menuIconTarget.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          `
        }
        
        // Hide after animation completes
        setTimeout(() => {
          if (!this.isMobileMenuOpen) {
            this.mobileMenuTarget.classList.add("hidden")
          }
        }, 250)
      }
    }
  }
  
  closeMobile() {
    if (this.isMobileMenuOpen) {
      this.isMobileMenuOpen = false
      
      if (this.hasMobileMenuTarget) {
        this.mobileMenuTarget.classList.remove("mobile-menu-enter")
        this.mobileMenuTarget.classList.add("mobile-menu-exit")
        
        if (this.hasMenuIconTarget) {
          this.menuIconTarget.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          `
        }
        
        setTimeout(() => {
          this.mobileMenuTarget.classList.add("hidden")
        }, 250)
      }
    }
  }
}
