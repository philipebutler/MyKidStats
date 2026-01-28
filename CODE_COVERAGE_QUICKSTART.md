# Quick Start: Code Coverage

## TL;DR

Code coverage is now enabled! Just run tests normally and view coverage in Xcode.

## Quick Commands

### In Xcode
```
⌘+U (Command+U) - Run all tests with coverage
⌘+9 - Open Report Navigator to view coverage
```

### Command Line
```bash
# Run tests with coverage
xcodebuild test -scheme MyKidStats \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult
```

## What Changed

1. ✅ **Project Settings Updated**
   - `CLANG_ENABLE_CODE_COVERAGE = YES` for test targets
   - Shared scheme created with coverage enabled

2. ✅ **Documentation Added**
   - `CODE_COVERAGE.md` - Complete guide
   - This quick start guide

3. ✅ **CI/CD Ready**
   - `.github/workflows/test-coverage.yml` - GitHub Actions workflow
   - Automated coverage reporting on PRs

## Coverage Goals

- **Overall**: 70-80%
- **Business Logic**: 90%+
- **View Models**: 80%+
- **UI Views**: 50%+

## Current Test Suite

- **11 test files** (~996 lines)
- **Categories**: Unit, Integration, Performance
- **Coverage**: Core Data, stat calculations, view models, exports

## View Coverage in Xcode

1. Run tests (⌘+U)
2. Open Report Navigator (⌘+9)
3. Select latest test run
4. Click "Coverage" tab
5. Expand files to see line coverage

## Tips

- Focus on testing behavior, not achieving 100% coverage
- Review uncovered code - it might need tests or be unused
- Check coverage for new code in PRs
- Don't sacrifice test quality for coverage numbers

## More Info

See [CODE_COVERAGE.md](./CODE_COVERAGE.md) for the complete guide including:
- Detailed setup instructions
- CI/CD integration examples
- Troubleshooting
- Best practices

---

**Questions?** Check the main documentation or ask the team!
