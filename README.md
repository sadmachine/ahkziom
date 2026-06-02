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

## Running Suite Files

Suite files can be directly executable and choose their own renderer:

```ahk
run_output := SuiteRunner.runSuiteInstances([MySuite()])
CliRenderer("*").render(run_output)
ExitApp run_output.counts.failed + run_output.counts.errored > 0 ? 1 : 0
```

## Documentation

- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api-reference.md)
- [Result Format](docs/result-format.md)
- [Contributor Guide](docs/contributor-guide.md)

## Future Improvements

- JSON exporter support for CI and tool integration.
- CLI launcher with flags for filtering, listing, or watching suites.
