# SCSS Theme Structure and Compilation Guide

## Theme Structure

Below you can see the structure of the **assets/scss** folder that contains all the SCSS files:

```
ckanext/scss/assets/scss/
│
├── base/
│   ├── _fonts.scss
│   └── _reset.scss
│
├── abstracts/
│   ├── _animations.scss
│   ├── _functions.scss
│   ├── _mixins.scss
│   ├── _placeholders.scss
│   ├── _primitives.scss
│   └── _variables.scss
│
├── components/
│   ├── _badges.scss
│   ├── _breadcrumb.scss
│   ├── _buttons.scss
│   ├── _dropdown.scss
│   ├── _facets.scss
│   ├── _forms.scss
│   ├── _pagination.scss
│   ├── _tables.scss
│   └── _tooltip.scss
│
├── layout/
│   ├── _header.scss
│   └── _footer.scss
│
├── pages/
│   ├── _dataset.scss
│   ├── _home.scss
│   └── _resource.scss
│
└── main.scss
```

## Compiling Styles

### Prerequisites

Install **NVM** (Node Version Manager) to manage different versions of **Node.js** on your local machine.

See the official [documentation](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) for installation instructions.

### Setup Process

1. From the project folder, run `nvm i` to install the required version of **Node.js** specified in the `.nvmrc` file.
2. Install project dependencies using **NPM** (Node Package Manager), which comes bundled with Node.js:
   
   ```sh
   npm ci
   ```
   
   This command performs a "clean install" using the `package-lock.json` file to ensure consistent dependency versions.
3. When you have it, write `nvm i` from the project folder, to install the required version of `node`. It's specified in the
   `.nvmrc` file.

### Compiling Commands

1. Development Mode:
   
   ```sh
   npm run dev
   ```
   
   This command enters watch mode, tracking changes to any SCSS file in the **theme** folder and includes source maps for debugging.
2. Production Build:
   
   ```sh
   npm run build
   ```
   
   This command creates minified style files for production. Run this when you're ready to deploy your changes.

# Front-end Styling Guide: Bootstrap 5 with Sass

## 1. Mobile-First Approach

Bootstrap 5 follows a mobile-first approach, which means we design and develop for mobile devices first, then progressively enhance the experience for larger screens. This methodology ensures optimal user experience across all devices and screen sizes.

### Why Mobile-First?

* Mobile usage continues to grow and often exceeds desktop usage
* Forces us to prioritize content and features for the smallest screens
* Leads to cleaner, more efficient CSS with fewer overrides
* Improves page load performance for mobile users

### Implementation Example

Here's an example of a card component developed with the mobile-first approach:

```scss
@use "abstracts/mixins" as m;

.card-component {
    padding: 1rem;
    margin-bottom: 1rem;

    .card-component__title {
        font-size: 1.25rem;
        margin-bottom: 0.5rem;
    }

    .card-component__content {
        font-size: 0.875rem;
    }

    // Enhanced styles for tablets (sm)
    @include m.media-breakpoint-up(sm) {
        padding: 1.5rem;

        .card-component__title {
            font-size: 1.5rem;
        }

        .card-component__content {
            font-size: 1rem;
        }
    }

    // Enhanced styles for desktops (lg)
    @include m.media-breakpoint-up(lg) {
        display: flex;

        .card-component__title {
            font-size: 1.75rem;
            flex: 0 0 30%;
        }

        .card-component__content {
            flex: 0 0 70%;
            padding-left: 1.5rem;
        }
    }
}
```

Note how we first define the base styles for mobile, then apply responsive enhancements for larger screen sizes using Bootstrap's media query mixins.

## 2. Component-Based Approach

A component-based approach to styling treats each user interface element as an independent, reusable component with its own styles, rather than styling pages as a whole.

### Benefits

* **Reusability**: Components can be reused across different pages
* **Maintainability**: Easier to understand, debug, and modify isolated components
* **Scalability**: New team members can work on individual components without affecting others
* **Consistency**: Promotes a unified look and feel throughout the application

### Guidelines

* Create a separate SCSS file for each component
* Focus on making components self-contained and independent
* Only use page-level styling as a last resort, for truly page-specific layouts
* Structure your project to reflect component organization:

```
scss/
├── abstracts/
│   ├── _variables.scss
│   ├── _functions.scss
│   ├── _mixins.scss
├── components/
│   ├── _buttons.scss
│   ├── _cards.scss
│   ├── _forms.scss
│   ├── _navbar.scss
├── layouts/
│   ├── _header.scss
│   ├── _footer.scss
│   ├── _sidebar.scss
├── pages/
│   ├── _home.scss
│   ├── _about.scss
└── main.scss
```

## 3. BEM Naming Methodology

BEM (Block, Element, Modifier) is a naming convention for CSS classes that helps create clear, strict relationships between HTML and CSS.

### Structure

* **Block**: Standalone entity that is meaningful on its own (e.g., `card`)
* **Element**: Parts of a block with no standalone meaning (e.g., `card__title`)
* **Modifier**: Flags on blocks or elements to change appearance or behavior (e.g., `card--featured`)

### Syntax

```
.block {}
.block__element {}
.block--modifier {}
.block__element--modifier {}
```

### Example

```html
<div class="card card--featured">
  <h2 class="card__title">Card Title</h2>
  <div class="card__content">
    <p class="card__text">Card content goes here</p>
    <button class="card__button card__button--primary">Read More</button>
  </div>
</div>
```

```scss
.card {
  background: #fff;
  border-radius: 4px;
  padding: 1rem;
  
  &--featured {
    border-left: 4px solid $primary-color;
  }
  
  &__title {
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }
  
  &__content {
    color: $text-color;
  }
  
  &__button {
    padding: 0.5rem 1rem;
  
    &--primary {
      background-color: $primary-color;
      color: white;
    }
  }
}
```

### Benefits

* Creates a clear, logical structure
* Helps prevent specificity issues and deep nesting
* Makes code more readable and maintainable
* Makes it easier to understand relationships between HTML and CSS

## 4. Bootstrap 5 Classes

Bootstrap 5 provides a comprehensive set of utility classes for common styling needs. While learning all of them can be overwhelming, we should leverage certain utility classes to maintain consistency and reduce custom CSS.

### Documentation References

* [Bootstrap 5 Documentation](https://getbootstrap.com/docs/5.0/getting-started/introduction/)
* [Bootstrap 5 Utility Classes](https://getbootstrap.com/docs/5.0/utilities/api/)

### Recommended Utility Classes to Use

* **Layout & Flexbox**: `d-flex`, `d-inline-flex`, `flex-row`, `flex-column`, `justify-content-*`, `align-items-*`
* **Spacing**: `m-*`, `p-*`, `mx-*`, `my-*`, `px-*`, `py-*`
* **Display & Visibility**: `d-none`, `d-block`, `d-*-none`, `d-*-block`
* **Text alignment**: `text-start`, `text-center`, `text-end`

### Example

```html
<div class="d-flex justify-content-between align-items-center mb-3 p-2">
  <h2 class="m-0">Title</h2>
  <button class="btn btn-primary d-none d-md-block">Desktop Action</button>
  <button class="btn btn-primary d-md-none">Mobile</button>
</div>
```

This creates a flexbox container with space-between justification, centered alignment, margin-bottom, and padding. It also shows different buttons based on screen size.

## 5. Sass Variables

Sass variables provide a way to store information to be reused throughout your stylesheet. They help maintain consistency and make global changes simpler.

### Benefits

* Single source of truth for values used repeatedly
* Easier updates and maintenance
* Support for mathematical operations and functions like `lighten()` and `darken()`
* Allow for more complex organization using maps

### Examples

```scss
// Basic variables
$primary-color: #007bff;
$secondary-color: #6c757d;
$border-radius: 4px;
$transition-speed: 0.3s;

// Creating related shades with Sass functions
$primary-light: lighten($primary-color, 15%);
$primary-dark: darken($primary-color, 15%);

// Maps for organized collections
$breakpoints: (
  "sm": 576px,
  "md": 768px,
  "lg": 992px,
  "xl": 1200px
);

// Using variables
.button {
  background-color: $primary-color;
  border-radius: $border-radius;
  transition: all $transition-speed ease;
  
  &:hover {
    background-color: $primary-dark;
  }
}

// Getting values from maps
@media (min-width: map-get($breakpoints, "md")) {
  // Tablet styles
}
```

### Note on CSS Variables

While CSS variables (custom properties) offer runtime manipulation, we're currently using Sass variables because:

1. We need to use Sass functions like `lighten()` and `darken()`
2. They're processed at compile time, offering broader browser support
3. They integrate seamlessly with the rest of our Sass architecture

## 6. Using REM Units

REM (Root EM) units are relative to the font size of the root element (typically the `<html>` element), which defaults to 16px in most browsers.

### Advantages

* **Accessibility**: Respects user's font size preferences
* **Consistency**: All measurements scale proportionally
* **Simplicity**: Easy to calculate and maintain relative sizing
* **Responsive**: Scales across different screen sizes

### Best Practices

* Use REMs for font sizes, margins, paddings, and most layout measurements
* Use pixels for very small details like borders, shadows, or when exact precision is required
* Set a base font size on the HTML element (often 16px, or sometimes 10px for easier calculations)
* Use a helper function to convert from pixels to REMs for more intuitive development:

```scss
@function to-rem($pixels, $context: 16px) {
  @if (math.is-unitless($pixels)) {
    $pixels: $pixels * 1px;
  }
  
  @if (math.is-unitless($context)) {
    $context: $context * 1px;
  }
  
  @return math.div($pixels, $context) * 1rem;
}

// Usage
.element {
  font-size: to-rem(18px);
  margin-bottom: to-rem(24px);
}
```

## 7. Sass Mixins

Mixins are reusable blocks of CSS declarations that can be included in other rule sets. They allow you to create reusable styles and even accept parameters for customized output.

### When to Use Mixins

* For frequently repeated groups of CSS declarations
* When you need to generate variants of a pattern with different values
* For cross-browser compatibility fixes
* For complex operations that need parameters

### Example Mixins

```scss
// Basic mixin for flexbox
@mixin flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

// Mixin with parameters for custom transitions
@mixin custom-transition($property: all, $duration: 0.3s, $timing: ease) {
  transition: $property $duration $timing;
}

// Complex mixin for responsive typography
@mixin responsive-font($min-size, $max-size, $min-width: 320px, $max-width: 1200px) {
  font-size: $min-size;
  
  @media (min-width: $min-width) {
    font-size: calc(#{$min-size} + #{strip-unit($max-size - $min-size)} * ((100vw - #{$min-width}) / #{strip-unit($max-width - $min-width)}));
  }
  
  @media (min-width: $max-width) {
    font-size: $max-size;
  }
}

// Usage
.container {
  @include flex-center;
}

.button {
  @include custom-transition(background-color, 0.2s, ease-in-out);
}

h1 {
  @include responsive-font(1.5rem, 3rem);
}
```

### Mixin vs. Extend

* Use **mixins** when you need to pass parameters or create variants
* Use **extends** when you have identical styles to share with no customization
* Mixins duplicate code in the output CSS (larger file size but more predictable)
* Extends combine selectors in the output CSS (smaller file size but can create complexity)

