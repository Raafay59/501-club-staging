import { Controller } from "@hotwired/stimulus"

// Controls scroll-triggered animations 
export default class extends Controller {
  connect() {
    this.observeElements()
  }
  
  observeElements() {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("animate-fade-up")
            entry.target.classList.remove("animate-init")
            observer.unobserve(entry.target)
          }
        })
      },
      {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px"
      }
    )
    
    // Observe all elements with animate-init class within this controller's scope
    const animateElements = this.element.querySelectorAll(".animate-init")
    animateElements.forEach((el) => observer.observe(el))
    
    // Bento cards 
    const bentoCards = this.element.querySelectorAll(".bento-card")
    bentoCards.forEach((el, index) => {
      el.style.opacity = "0"
      el.style.transform = "translateY(20px)"
      el.style.transition = "opacity 0.6s ease-out, transform 0.6s ease-out"
      
      const cardObserver = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              setTimeout(() => {
                entry.target.style.opacity = "1"
                entry.target.style.transform = "translateY(0)"
              }, index * 100)
              cardObserver.unobserve(entry.target)
            }
          })
        },
        { threshold: 0.1 }
      )
      
      cardObserver.observe(el)
    })
  }
}
