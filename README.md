# ahkxiom

An AutoHotkey v2 testing library.

## Quick Start

```ahk
#Include src/Ahkxiom.ahk

class MySuite extends TestSuiteBase
{
    sampleTest() {
        d := this.describe("Math checks")
        d.it("adds numbers").expect(2 + 2).toBe(4)
    }
}

run_output := SuiteRunner.runSuiteInstance(MySuite())
MsgBox CliRenderer().render(run_output)
```

## Documentation

- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api-reference.md)
- [Result Format](docs/result-format.md)
- [Contributor Guide](docs/contributor-guide.md)
