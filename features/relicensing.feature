Feature: Relicensing
    As a developer with a project with many licenses
    I want to know if I can relicense it in my terms
    So I can control which rights my users have.

        Scenario: Is BSD relicensable to GPL?
            Given I run local executable "licc" with arguments "bsd --to gpl"
            Then it should exit successfully

