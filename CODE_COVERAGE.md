# Code Coverage Guide for MyKidStats

## Overview

Code coverage has been enabled for the MyKidStats test suite to help maintain code quality and ensure comprehensive test coverage. This document explains how to use code coverage features during development and in CI/CD pipelines.

## What is Code Coverage?

Code coverage measures which parts of your code are executed during testing. It helps identify:
- Untested code paths
- Areas that need more test coverage
- Dead or unreachable code
- The effectiveness of your test suite

## Current Test Suite

The MyKidStats project includes:
- **Unit Tests**: `MyKidStatsTests` target (11 test files, ~996 lines)
- **UI Tests**: `MyKidStatsUITests` target
- **Performance Tests**: Included in unit tests

### Test Categories
- Core Data entities and relationships
- Stat recording and calculation logic
- View model state management
- Export functionality (CSV, text)
- Navigation coordination
- Performance benchmarks (<50ms stat recording)

## Enabling Code Coverage

Code coverage is now **enabled by default** in the project configuration:

### Xcode Project Settings
- ✅ `CLANG_ENABLE_CODE_COVERAGE = YES` for MyKidStatsTests (Debug & Release)
- ✅ `CLANG_ENABLE_CODE_COVERAGE = YES` for MyKidStatsUITests (Debug & Release)
- ✅ Shared scheme includes `codeCoverageEnabled = "YES"`

### What This Means
When you run tests, Xcode will automatically collect coverage data for:
- All source files in the main target
- Swift and Objective-C code
- Line-by-line execution tracking

## Running Tests with Code Coverage

### In Xcode (Recommended)

1. **Open the project in Xcode**
   ```bash
   open MyKidStats.xcodeproj
   ```

2. **Run tests with coverage**
   - Press `⌘+U` (Command+U) to run all tests
   - Or: Product → Test from the menu

3. **View coverage report**
   - After tests complete, open the Report Navigator (⌘+9)
   - Select the latest test run
   - Click the "Coverage" tab

4. **View detailed coverage**
   - In Coverage tab, expand files to see line-by-line coverage
   - Green = covered, red = not covered
   - Click any file to see source with coverage highlighting

### Command Line

For CI/CD pipelines or command-line workflows:

```bash
# Run tests and generate coverage report
xcodebuild test \
  -scheme MyKidStats \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES \
  -derivedDataPath ./DerivedData

# Generate human-readable coverage report
xcrun xccov view \
  --report \
  --json \
  ./DerivedData/Logs/Test/*.xcresult > coverage.json

# View coverage summary
xcrun xccov view \
  --report \
  ./DerivedData/Logs/Test/*.xcresult
```

### Export Coverage to Xcode Format

```bash
# Export to .xccoverage format
xcrun xccov view \
  --archive \
  ./DerivedData/Logs/Test/*.xcresult
```

## Understanding Coverage Reports

### Coverage Metrics

- **Line Coverage**: Percentage of lines executed
- **Function Coverage**: Percentage of functions called
- **Branch Coverage**: Percentage of decision branches taken

### Example Coverage Report

```
MyKidStats.app:
  LiveGameViewModel.swift: 95.2% (60/63 lines)
  CalculateCareerStatsUseCase.swift: 98.5% (133/135 lines)
  StatType.swift: 100% (45/45 lines)
  HomeViewModel.swift: 87.3% (55/63 lines)
```

### What to Look For

✅ **Good Coverage (>80%)**
- Core business logic
- Data models and use cases
- View models
- Critical user flows

⚠️ **Expected Lower Coverage**
- UI views (SwiftUI) - harder to unit test
- App initialization code
- Debug/development utilities
- Error handling edge cases

## Coverage Goals

### Target Coverage Levels

- **Overall Project**: Target 70-80% coverage
- **Business Logic**: Target 90%+ coverage
  - Use cases (CalculateCareerStatsUseCase, etc.)
  - Domain models (LiveStats, CareerStats)
  - Core Data extensions
- **View Models**: Target 80%+ coverage
- **UI Views**: Target 50%+ coverage (via UI tests)

### Current Baseline

As of implementation (Jan 2026):
- Test suite: 11 files, ~996 lines of test code
- Coverage: To be measured after first run
- Well-covered: Core Data, stat calculations, view models
- Needs coverage: Some UI-specific code paths

## Best Practices

### Writing Tests for Coverage

1. **Focus on behavior, not coverage numbers**
   - Coverage is a metric, not a goal
   - Write meaningful tests that verify behavior

2. **Test critical paths first**
   - Stat recording (must be <50ms)
   - Score calculations
   - Data persistence
   - Game flow

3. **Don't ignore uncovered code**
   - Review why code isn't covered
   - Add tests if it's important functionality
   - Remove code if it's dead/unreachable

4. **Use coverage to find bugs**
   - Uncovered code may indicate missing test cases
   - Look for untested error paths
   - Check edge cases

### Continuous Improvement

- Review coverage reports after each PR
- Aim to maintain or improve coverage
- Don't sacrifice test quality for coverage numbers
- Document intentionally untested code

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test-coverage.yml`:

```yaml
name: Tests & Coverage

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.2.app
    
    - name: Run tests with coverage
      run: |
        xcodebuild test \
          -scheme MyKidStats \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
          -enableCodeCoverage YES \
          -derivedDataPath ./DerivedData
    
    - name: Generate coverage report
      run: |
        xcrun xccov view \
          --report \
          --json \
          ./DerivedData/Logs/Test/*.xcresult > coverage.json
        
        # Print summary
        xcrun xccov view --report ./DerivedData/Logs/Test/*.xcresult
    
    - name: Upload coverage reports
      uses: actions/upload-artifact@v3
      with:
        name: coverage-report
        path: coverage.json
```

### Coverage Badges

To add a coverage badge to your README:

1. Use a service like [Codecov](https://codecov.io) or [Coveralls](https://coveralls.io)
2. Configure the service to read Xcode coverage reports
3. Add badge markdown to README.md:

```markdown
[![codecov](https://codecov.io/gh/username/MyKidStats/branch/main/graph/badge.svg)](https://codecov.io/gh/username/MyKidStats)
```

## Troubleshooting

### Coverage Not Appearing

1. **Check scheme settings**
   - Ensure "Gather coverage for" includes all targets
   - Verify "Test" action has coverage enabled

2. **Clean build folder**
   ```bash
   # In Xcode: Product → Clean Build Folder (⌘+Shift+K)
   # Or command line:
   xcodebuild clean -scheme MyKidStats
   ```

3. **Check test execution**
   - Ensure tests are actually running
   - Look for test failures that might abort coverage collection

### Coverage Data Missing for Files

1. **Verify file is in target**
   - Check file's Target Membership in Xcode
   - Ensure file is compiled into the app target

2. **Check for compiler optimizations**
   - Coverage works best with Debug configuration
   - Ensure optimizations don't eliminate code

### Can't Find .xcresult File

```bash
# Find all test results
find ~/Library/Developer/Xcode/DerivedData -name "*.xcresult"

# Use most recent
ls -lt ~/Library/Developer/Xcode/DerivedData/*/Logs/Test/*.xcresult | head -1
```

## Additional Resources

### Xcode Documentation
- [Code Coverage in Xcode](https://developer.apple.com/documentation/xcode/code-coverage)
- [xccov Command Reference](https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/)

### Testing Best Practices
- [Testing Swift Code](https://developer.apple.com/documentation/xctest)
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

### Tools
- [xcov](https://github.com/fastlane-community/xcov) - Fastlane plugin for coverage
- [slather](https://github.com/SlatherOrg/slather) - Alternative coverage tool

## Maintenance

This document should be updated when:
- Test suite structure changes significantly
- Coverage goals are adjusted
- New testing tools are adopted
- CI/CD pipeline changes

---

**Last Updated**: January 2026  
**Maintained By**: Development Team  
**Questions?**: See [TEST_REVIEW_SUMMARY.md](./TEST_REVIEW_SUMMARY.md) for test suite details
