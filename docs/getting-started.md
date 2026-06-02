# Getting Started

## Include The Library

```ahk
#Include src/Ahkxiom.ahk
```

## Create A Test Suite

Test suites extend `TestSuiteBase`. Every non-underscore instance method is treated as a test entrypoint, except the reserved lifecycle methods.

```ahk
class MathSuite extends TestSuiteBase
{
    beforeEach() {
    }

    sampleTest() {
        d := this.describe("Math checks")
        d.it("adds numbers").expect(2 + 2).toBe(4)
    }

    _helper() {
    }
}
```

## Lifecycle Hooks

The framework reserves these non-test methods:

- `beforeAll()`
- `afterAll()`
- `beforeEach()`
- `afterEach()`

These methods are available for suite setup and cleanup, but they are not discovered as tests.

## Group Assertions With `describe()`

Use `describe()` to group related checks inside one discovered test method.

```ahk
sampleTest() {
    d := this.describe("Truth checks")
    d.it("true stays truthy").expect(true).toBeTruthy()
    d.it("empty string stays empty").expect("").toBeEmpty()
}
```

## Use Fail-Fast When Needed

By default, assertions continue after failures. Use `failFast()` when a later check should not run after an earlier failure.

```ahk
sampleTest() {
    d := this.describe("Critical checks").failFast(true)
    d.it("stop on first failure").failFast(true).expect(1).toBe(2)
}
```

## Check Whether A Variable Is Defined

Use `expectVar(() => x).toBeDefined()` when you need AHK variable-definedness semantics rather than ordinary value comparison.

```ahk
sampleTest() {
    x := 10
    this.describe("Variable checks")
        .it("x is defined")
        .expectVar(() => x)
        .toBeDefined()
}
```

## Run A Suite And Render Output

```ahk
run_output := SuiteRunner.runSuiteInstance(MathSuite())
output := CliRenderer().render(run_output)
MsgBox output
```

## Run A Suite File From The CLI

Suite files can be directly executable scripts. The suite file chooses its renderer, so CLI output today and future GUI renderers can use the same result objects.

```ahk
#Requires AutoHotkey v2.0
#Include src/Ahkxiom.ahk

class MathSuite extends TestSuiteBase
{
    sampleTest() {
        d := this.describe("Math checks")
        d.it("adds numbers").expect(2 + 2).toBe(4)
    }
}

run_output := SuiteRunner.runSuiteInstances([MathSuite()])
CliRenderer("*").render(run_output)
ExitApp run_output.counts.failed + run_output.counts.errored > 0 ? 1 : 0
```

## Recommended Practices

- Keep each suite focused on one concern.
- Use underscore-prefixed helper methods for non-test logic.
- Write `it(...)` descriptions that explain intent clearly.
- Use `expectVar(() => x)` only when definedness semantics matter.
