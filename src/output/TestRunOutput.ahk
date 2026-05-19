#Requires AutoHotkey v2.0

class TestRunOutput
{
    __New(schema_version, run_id, created_at) {
        this.schemaVersion := schema_version
        this.runId := run_id
        this.createdAt := created_at
        this.metadata := Map()
        this.suites := []
        this.counts := CountOutput()
    }

    addSuite(suite_output) {
        this.suites.Push(suite_output)
        return suite_output
    }
}
