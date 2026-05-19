#Requires AutoHotkey v2.0

class AssertionCase
{
    __New(describe_scope, description, skipped := false) {
        this.describeScope := describe_scope
        this.description := description
        this.hasFailFastOverride := false
        this.failFastOverride := false
        this.skipped := skipped
    }

    failFast(enabled := true) {
        this.hasFailFastOverride := true
        this.failFastOverride := enabled
        return this
    }

    expect(actual) {
        return Expectation(this, actual)
    }

    expectVar(value_factory) {
        return Expectation(this, unset, value_factory)
    }
}
