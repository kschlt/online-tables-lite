# Frontend Structure Documentation

## Directory Organization

```
src/
├── app/                    # Next.js App Router pages
│   ├── layout.tsx         # Root layout
│   ├── page.tsx          # Home page
│   └── table/[slug]/     # Dynamic table routes
├── components/            # Reusable React components
│   ├── ui/               # Generic UI components
│   └── table/            # Table-specific components
├── hooks/                # Custom React hooks
├── lib/                  # Utility libraries and API clients
├── types/                # TypeScript type definitions
├── constants/            # Application constants
└── utils/                # General utility functions
```

## Key Features

### Type Safety

- Centralized TypeScript types in `types/`
- Strict type checking enabled
- Proper interface definitions for API responses

### Component Architecture

- Separation of UI components from business logic
- Reusable components with consistent styling
- Custom hooks for data fetching and state management

### API Integration

- Native fetch() only (per CLAUDE.md requirements)
- Centralized API client with error handling
- Type-safe request/response handling

### Code Organization

- Barrel exports for clean imports
- Consistent naming conventions
- Path aliases for clean import statements

## Best Practices Implemented

1. **Component Design**: Small, focused components with single responsibilities
2. **Custom Hooks**: Business logic extracted into reusable hooks
3. **Error Handling**: Comprehensive error states and user feedback
4. **Loading States**: Consistent loading indicators and skeleton states
5. **TypeScript**: Full type coverage with strict mode enabled
6. **Linting**: Zero warnings policy with comprehensive ESLint rules

## Integration with Backend

- Uses centralized API constants
- Token-based authentication
- Error handling for API failures
- Type-safe data models matching backend Pydantic schemas
