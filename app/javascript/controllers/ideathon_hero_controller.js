import { Controller } from "@hotwired/stimulus"

// Controls hero section animations on page load with professional staggered effects
export default class extends Controller {
  connect() {
    // Trigger fade-up animations with staggered timing for cinematic effect
    this.animateHero()
  }
  
  animateHero() {
    const animateElements = this.element.querySelectorAll(".animate-init")
    
    // Remove the init class with slight stagger for each element
    animateElements.forEach((el, index) => {
      setTimeout(() => {
        el.classList.remove("animate-init")
      }, 100 + (index * 50))
    })
    
    // Add counter animation to stats
    this.animateCounters()
  }
  
  animateCounters() {
    // Find stat elements and animate their numbers
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("counter-animate")
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.5 })
    
    // Observe all stat number elements
    const statsElements = this.element.querySelectorAll(".font-beachday")
    statsElements.forEach(el => observer.observe(el))
  }
}
