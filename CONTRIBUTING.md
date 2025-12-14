# Contributing Guide

Thank you for your interest in contributing to Dash Router! 🎉

## Code of Conduct

Please be kind and respectful to others. We welcome contributions from everyone.

## How to Contribute

### Reporting Bugs

1. Search [Issues](https://github.com/iota9star/dash_router/issues) to ensure the issue hasn't been reported
2. Create a new Issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Flutter/Dart version
   - Relevant code snippets

### Feature Requests

1. Search Issues to ensure the feature hasn't been requested
2. Create a new Issue describing:
   - Use case for the feature
   - Suggested API design
   - Possible implementation approach

### Submitting Code

1. **Fork the repository**

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/dash_router.git
   cd dash_router
   ```

3. **Install dependencies**
   ```bash
   # Install Melos
   dart pub global activate melos
   
   # Bootstrap
   melos bootstrap
   ```

4. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

5. **Make your changes**
   - Follow existing code style
   - Add test coverage
   - Update relevant documentation

6. **Run tests**
   ```bash
   melos run test
   ```

7. **Run analysis**
   ```bash
   melos run analyze
   ```

8. **Format code**
   ```bash
   melos run format
   ```

9. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   # or
   git commit -m "fix: fix some issue"
   ```

10. **Push and create PR**
    ```bash
    git push origin feature/your-feature-name
    ```
    Then create a Pull Request on GitHub.

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation update
- `style:` Code formatting (no code logic changes)
- `refactor:` Refactoring (neither new feature nor bug fix)
- `perf:` Performance improvement
- `test:` Test related
- `chore:` Build process or auxiliary tool changes

Examples:
```
feat(router): add route preloading feature
fix(generator): fix nested route generation error
docs(readme): update installation instructions
```

## Code Style

### Dart

- Use `dart format` to format code
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- All public APIs must have documentation comments

### Documentation

- README available in English and Chinese
- Code comments in English
- API documentation in English

## Project Structure

```
dash_router/
├── packages/
│   ├── dash_router/              # Core runtime library
│   ├── dash_router_annotations/  # Annotation definitions
│   ├── dash_router_generator/    # Code generator
│   └── dash_router_cli/          # CLI tool
├── example/                      # Example application
├── melos.yaml                    # Melos configuration
└── README.md
```

## Development Commands

```bash
# Bootstrap all packages
melos bootstrap

# Run all tests
melos run test

# Run analysis
melos run analyze

# Format code
melos run format

# Generate example route code
cd example && dart run dash_router_cli:dash_router generate
```

## Release Process

1. Update version numbers (follow semantic versioning)
2. Update CHANGELOG.md
3. Create Release PR
4. Merge to automatically publish to pub.dev

## Need Help?

- Create a [Discussion](https://github.com/iota9star/dash_router/discussions)
- Check the [Wiki](https://github.com/iota9star/dash_router/wiki)

Thank you again for your contribution! 🙏
