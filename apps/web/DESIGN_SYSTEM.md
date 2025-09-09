# Design System - Single Source of Truth

This document explains how to use our design system to maintain consistent styling across the application.

## 🎨 Changing Colors

To change colors throughout the application, edit the `brandColors` object in `src/lib/design-tokens.ts`:

```typescript
// Change primary brand color from blue to green
export const brandColors = {
  primary: {
    500: 'hsl(142 76% 36%)', // Changed from blue to green
    // ... other shades
  },
  // ... other colors
}
```

**This will automatically update:**

- All primary buttons
- Links and interactive elements
- Focus states
- Status indicators
- Charts and graphs

## 🔤 Changing Typography

To change fonts throughout the application, edit the `typography` object in `src/lib/design-tokens.ts`:

```typescript
export const typography = {
  fontFamily: {
    sans: ['Roboto', 'system-ui', 'sans-serif'], // Changed from Inter to Roboto
    mono: ['Fira Code', 'Consolas', 'monospace'], // Changed from JetBrains Mono to Fira Code
  },
  // ... other typography settings
}
```

**This will automatically update:**

- All text elements
- Headings
- Body text
- Code blocks
- Form inputs

## 📏 Changing Spacing

To change spacing throughout the application, edit the `spacing` object in `src/lib/design-tokens.ts`:

```typescript
export const spacing = {
  xs: '0.5rem', // Changed from 0.25rem to 0.5rem
  sm: '1rem', // Changed from 0.5rem to 1rem
  // ... other spacing values
}
```

**This will automatically update:**

- Component padding and margins
- Grid gaps
- Form spacing
- Card spacing

## 🎯 Using Design System Classes

### Button Variants

```tsx
// Primary button (uses brand primary color)
<button className="btn-primary">Primary Action</button>

// Secondary button (uses brand secondary color)
<button className="btn-secondary">Secondary Action</button>

// Success button (uses brand success color)
<button className="btn-success">Success Action</button>

// Warning button (uses brand warning color)
<button className="btn-warning">Warning Action</button>

// Error button (uses brand error color)
<button className="btn-error">Error Action</button>
```

### Status Indicators

```tsx
// Success status
<div className="status-success p-3 rounded-lg">
  Operation completed successfully
</div>

// Warning status
<div className="status-warning p-3 rounded-lg">
  Please review your input
</div>

// Error status
<div className="status-error p-3 rounded-lg">
  An error occurred
</div>

// Info status
<div className="status-info p-3 rounded-lg">
  Additional information
</div>
```

### Card Variants

```tsx
// Elevated card with shadow
<div className="card-elevated p-6">
  Card content with elevation
</div>

// Flat card without shadow
<div className="card-flat p-6">
  Card content without elevation
</div>
```

### Typography Classes

```tsx
// Headings
<h1 className="text-heading-1">Main Heading</h1>
<h2 className="text-heading-2">Section Heading</h2>
<h3 className="text-heading-3">Subsection Heading</h3>

// Body text
<p className="text-body">Main body text</p>
<p className="text-body-sm">Smaller body text</p>
<p className="text-caption">Caption text</p>
```

## 🔧 CSS Variables

The design system automatically generates CSS variables that you can use in custom CSS:

```css
.custom-component {
  background-color: var(--color-primary);
  color: var(--color-primary-light);
  font-family: var(--font-family-sans);
  padding: var(--spacing-md);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}
```

## 🎨 Available CSS Variables

### Colors

- `--color-primary` - Main brand color
- `--color-primary-hover` - Hover state for primary
- `--color-primary-light` - Light variant of primary
- `--color-secondary` - Secondary brand color
- `--color-success` - Success color
- `--color-warning` - Warning color
- `--color-error` - Error color

### Typography

- `--font-family-sans` - Sans-serif font stack
- `--font-family-mono` - Monospace font stack

### Spacing

- `--spacing-xs` - Extra small spacing
- `--spacing-sm` - Small spacing
- `--spacing-md` - Medium spacing
- `--spacing-lg` - Large spacing
- `--spacing-xl` - Extra large spacing

### Border Radius

- `--radius-sm` - Small border radius
- `--radius-md` - Medium border radius
- `--radius-lg` - Large border radius

### Shadows

- `--shadow-sm` - Small shadow
- `--shadow-md` - Medium shadow
- `--shadow-lg` - Large shadow

## 🚀 Quick Theme Changes

### Change Brand Color to Purple

```typescript
// In src/lib/design-tokens.ts
primary: {
  500: 'hsl(262 83% 58%)',  // Purple instead of blue
  600: 'hsl(262 83% 50%)',  // Darker purple for hover
  50: 'hsl(262 83% 97%)',   // Light purple for backgrounds
  // ... update other shades
}
```

### Change Font to Roboto

```typescript
// In src/lib/design-tokens.ts
fontFamily: {
  sans: ['Roboto', 'system-ui', 'sans-serif'],
  // ... keep mono unchanged
}
```

### Change Spacing Scale

```typescript
// In src/lib/design-tokens.ts
spacing: {
  xs: '0.5rem',    // Increase from 0.25rem
  sm: '1rem',      // Increase from 0.5rem
  md: '1.5rem',    // Increase from 1rem
  // ... update other values proportionally
}
```

## 📱 Responsive Design

The design system includes responsive utilities:

```tsx
// Responsive spacing
<div className="p-sm md:p-md lg:p-lg">
  Responsive padding
</div>

// Responsive typography
<h1 className="text-heading-2 md:text-heading-1">
  Responsive heading
</h1>

// Responsive colors
<div className="bg-primary-light md:bg-primary">
  Responsive background
</div>
```

## 🌙 Dark Mode Support

The design system automatically supports dark mode. Colors will automatically adjust based on the `dark` class on the root element.

## 🔄 Migration Guide

When updating existing components to use the design system:

1. **Replace hardcoded colors** with design system classes
2. **Replace hardcoded spacing** with design system spacing
3. **Replace hardcoded typography** with design system typography classes
4. **Use component variants** instead of custom styling

### Before (hardcoded)

```tsx
<div className="bg-blue-500 text-white p-4 rounded-lg shadow-md">
  <h2 className="text-xl font-bold">Title</h2>
</div>
```

### After (design system)

```tsx
<div className="card-elevated p-md">
  <h2 className="text-heading-3">Title</h2>
</div>
```

This ensures consistency and makes future theme changes much easier!
