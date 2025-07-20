// Mobile Navigation Toggle
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.querySelector('.nav-menu');
    
    // Create mobile menu
    const mobileMenu = document.createElement('div');
    mobileMenu.className = 'mobile-menu';
    // Clone nodes instead of innerHTML to preserve event listeners
    navMenu.childNodes.forEach(node => {
        if (node.nodeType === 1) { // Element node
            mobileMenu.appendChild(node.cloneNode(true));
        }
    });
    document.querySelector('.navbar').appendChild(mobileMenu);
    
    navToggle.addEventListener('click', function() {
        mobileMenu.classList.toggle('active');
        navToggle.classList.toggle('active');
    });
    
    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        if (!event.target.closest('.navbar')) {
            mobileMenu.classList.remove('active');
            navToggle.classList.remove('active');
        }
    });
    
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                // Close mobile menu after clicking
                mobileMenu.classList.remove('active');
                navToggle.classList.remove('active');
            }
        });
    });
    
    // Navbar background on scroll
    let lastScroll = 0;
    window.addEventListener('scroll', function() {
        const navbar = document.querySelector('.navbar');
        const currentScroll = window.pageYOffset;
        
        if (currentScroll > 50) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = '0 1px 2px 0 rgba(0, 0, 0, 0.05)';
        }
        
        lastScroll = currentScroll;
    });
    
    // Intersection Observer for animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);
    
    // Observe all feature cards and steps
    document.querySelectorAll('.feature-card, .step, .faq-item').forEach(el => {
        el.classList.add('fade-in');
        observer.observe(el);
    });
});

// Add CSS for mobile menu
const style = document.createElement('style');
style.textContent = `
    .mobile-menu {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: white;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.3s ease;
    }
    
    .mobile-menu.active {
        max-height: 400px;
    }
    
    .mobile-menu li {
        list-style: none;
        border-bottom: 1px solid #e5e7eb;
    }
    
    .mobile-menu a {
        display: block;
        padding: 1rem 2rem;
        text-decoration: none;
        color: #1f2937;
        font-weight: 500;
        transition: all 0.3s ease;
    }
    
    .mobile-menu a:hover {
        background: #f3f4f6;
        color: #22c55e;
    }
    
    .nav-toggle.active span:nth-child(1) {
        transform: rotate(45deg) translate(5px, 5px);
    }
    
    .nav-toggle.active span:nth-child(2) {
        opacity: 0;
    }
    
    .nav-toggle.active span:nth-child(3) {
        transform: rotate(-45deg) translate(7px, -6px);
    }
    
    .fade-in {
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.6s ease;
    }
    
    .fade-in.visible {
        opacity: 1;
        transform: translateY(0);
    }
    
    @media (max-width: 768px) {
        .mobile-menu {
            display: block;
        }
    }
`;
document.head.appendChild(style);