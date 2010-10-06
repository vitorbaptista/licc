Feature: Relicensing
    As a developer with a project with many licenses
    I want to know if I can relicense it in my terms
    So I can control which rights my users have.

        Scenario: Is BSD relicensable to GPL?
            Given I run local executable "licc" with arguments "bsd --to gpl"
            Then it should exit successfully

        Scenario: Is GPL relicensable to BSD?
            Given I run local executable "licc" with arguments "gpl --to bsd"
            Then it should not exit successfully

        Scenario: Is GPL relicensable to LGPL?
            Given I run local executable "licc" with arguments "gpl --to lgpl"
            Then it should not exit successfully

        Scenario: Is GPL relicensable to GPL?
            Given I run local executable "licc" with arguments "gpl --to gpl"
            Then it should exit successfully

        Scenario: Is BY-NC relicensable to BY?
            Given I run local executable "licc" with arguments "by-nc --to by"
            Then it should not exit successfully

        Scenario: Is BY-ND relicensable to BY?
            Given I run local executable "licc" with arguments "by-nd --to by"
            Then it should not exit successfully

        Scenario: Is BY-NC-ND relicensable to BY?
            Given I run local executable "licc" with arguments "by-nc-nd --to by"
            Then it should not exit successfully
