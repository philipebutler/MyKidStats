# Code Coverage Workflow Diagram

## Overview Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CODE COVERAGE WORKFLOW                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐
│  Developer   │
│  Makes Code  │
│   Changes    │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│                    RUN TESTS                                  │
│  ┌──────────────────────┐   ┌────────────────────────────┐  │
│  │   In Xcode (⌘+U)     │   │   Command Line             │  │
│  │   - Quick & Visual   │   │   - xcodebuild test        │  │
│  │   - Live feedback    │   │   - CI/CD friendly         │  │
│  └──────────────────────┘   └────────────────────────────┘  │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               COVERAGE DATA COLLECTION                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  CLANG_ENABLE_CODE_COVERAGE = YES                    │  │
│  │  - Instruments code during compilation               │  │
│  │  - Tracks line execution during tests                │  │
│  │  - Generates .profdata files                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  COVERAGE REPORTS                            │
│  ┌──────────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Xcode Report    │  │  JSON File   │  │  Text Report │  │
│  │  Navigator       │  │  (for tools) │  │  (readable)  │  │
│  │  ⌘+9 Coverage    │  │  coverage.json│  │  coverage.txt│  │
│  └──────────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    REVIEW & ACTION                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Developer Actions:                                   │  │
│  │  - Identify untested code                            │  │
│  │  - Add tests for critical paths                      │  │
│  │  - Remove dead code                                  │  │
│  │  - Improve test quality                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## CI/CD Integration

```
┌──────────────┐
│   PR/Push    │
│  to GitHub   │
└──────┬───────┘
       │
       ▼
┌────────────────────────────────────────────────────────┐
│         GitHub Actions Workflow Triggers                │
│  (.github/workflows/test-coverage.yml)                 │
└─────────────────────┬──────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────────────────┐
│              Run Tests in CI Environment                │
│  - macOS runner with Xcode                             │
│  - iOS Simulator                                       │
│  - Coverage enabled by default                         │
└─────────────────────┬──────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────────────────┐
│           Generate Coverage Reports                     │
│  - xcrun xccov for JSON/text reports                   │
│  - Extract coverage percentage                         │
│  - Check against threshold (70%)                       │
└─────────────────────┬──────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────────────────┐
│              Publish Results                            │
│  ┌────────────────────────────────────────────────┐   │
│  │  • Comment on PR with coverage summary         │   │
│  │  • Upload artifacts for detailed analysis      │   │
│  │  • Show in GitHub Actions summary              │   │
│  │  • Fail if below threshold (optional)          │   │
│  └────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────┘
```

## Coverage Analysis Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Coverage Data                         │
│         (Collected during test execution)                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│              File-Level Analysis                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  File: LiveGameViewModel.swift                   │  │
│  │  Lines: 95.2% (60/63)                            │  │
│  │  Functions: 100% (12/12)                         │  │
│  │  Branches: 88.5% (23/26)                         │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│            Line-by-Line Analysis                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Line 45: ✅ Covered (executed 15 times)         │  │
│  │  Line 46: ✅ Covered (executed 15 times)         │  │
│  │  Line 47: ❌ Not covered                         │  │
│  │  Line 48: ❌ Not covered                         │  │
│  │  Line 49: ✅ Covered (executed 8 times)          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                Action Items                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Lines 47-48: Error handling path                │  │
│  │  Action: Add test for error case                 │  │
│  │  Priority: High (error path should be tested)    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Coverage Goals Hierarchy

```
┌────────────────────────────────────────────────────────────┐
│                   OVERALL PROJECT                          │
│                   Target: 70-80%                           │
│                                                            │
│  ┌──────────────────────────────────────────────────┐    │
│  │           BUSINESS LOGIC LAYER                    │    │
│  │           Target: 90%+                            │    │
│  │                                                    │    │
│  │  ┌────────────────────────────────────────┐      │    │
│  │  │  Use Cases                             │      │    │
│  │  │  - CalculateCareerStatsUseCase        │      │    │
│  │  │  - ExportGameCSVUseCase               │      │    │
│  │  │  - GenerateTextSummaryUseCase         │      │    │
│  │  │  Target: 90%+                         │      │    │
│  │  └────────────────────────────────────────┘      │    │
│  │                                                    │    │
│  │  ┌────────────────────────────────────────┐      │    │
│  │  │  Domain Models                         │      │    │
│  │  │  - LiveStats                           │      │    │
│  │  │  - CareerStats                         │      │    │
│  │  │  - StatType enum                       │      │    │
│  │  │  Target: 90%+                         │      │    │
│  │  └────────────────────────────────────────┘      │    │
│  └──────────────────────────────────────────────────┘    │
│                                                            │
│  ┌──────────────────────────────────────────────────┐    │
│  │          VIEW MODELS LAYER                        │    │
│  │          Target: 80%+                             │    │
│  │                                                    │    │
│  │  - LiveGameViewModel                              │    │
│  │  - HomeViewModel                                  │    │
│  │  - StatsViewModel                                 │    │
│  └──────────────────────────────────────────────────┘    │
│                                                            │
│  ┌──────────────────────────────────────────────────┐    │
│  │           UI LAYER                                │    │
│  │           Target: 50%+                            │    │
│  │                                                    │    │
│  │  - Views (SwiftUI)                                │    │
│  │  - Components                                     │    │
│  │  - Navigation                                     │    │
│  └──────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────┘
```

## Test Execution with Coverage

```
Test Run Started
    │
    ├─> LiveGameViewModelTests
    │   ├─> testRecordStat() ✅ (covers 25 lines)
    │   ├─> testUndoAction() ✅ (covers 18 lines)
    │   └─> testEndGame() ✅ (covers 12 lines)
    │
    ├─> CalculateCareerStatsUseCaseTests
    │   ├─> testBasicCalculation() ✅ (covers 45 lines)
    │   ├─> testCareerHighs() ✅ (covers 32 lines)
    │   └─> testTeamBreakdown() ✅ (covers 28 lines)
    │
    ├─> GameFlowTests
    │   └─> testCompleteGameFlow() ✅ (covers 67 lines)
    │
    └─> Performance Tests
        ├─> testStatRecordingSpeed() ✅ (<50ms requirement)
        └─> testCareerStatsPerformance() ✅ (large datasets)

Test Run Complete
    │
    └─> Coverage Data Generated
        ├─> Lines executed: 825/1050 (78.6%)
        ├─> Functions called: 142/165 (86.1%)
        └─> Branches taken: 189/245 (77.1%)
```

## Decision Tree: Is Coverage Adequate?

```
Start: Review coverage for new/changed code
    │
    ├─> Is overall coverage > 70%?
    │   ├─> YES → ✅ Good overall coverage
    │   └─> NO → ⚠️  Consider adding more tests
    │
    ├─> Is business logic coverage > 90%?
    │   ├─> YES → ✅ Critical code well tested
    │   └─> NO → ❌ Add tests for business logic
    │
    ├─> Are error paths covered?
    │   ├─> YES → ✅ Robust error handling
    │   └─> NO → ⚠️  Add error case tests
    │
    ├─> Are edge cases covered?
    │   ├─> YES → ✅ Thorough testing
    │   └─> NO → ⚠️  Add edge case tests
    │
    └─> Is performance tested?
        ├─> YES → ✅ Performance validated
        └─> NO → ⚠️  Add performance tests if critical

Result: Coverage is adequate when:
    - Overall > 70%
    - Business logic > 90%
    - Critical paths covered
    - Error handling tested
    - Key performance validated
```

## Legend

```
✅ Covered/Complete
❌ Not covered/Missing
⚠️  Warning/Action needed
▼ Flow direction
├─ Branch
└─ End branch
```
