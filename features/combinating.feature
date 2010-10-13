Feature: Combinating
    As a developer of a project with many licenses
    I want to know if I can combine those licenses
    So I can know if I am complying with the other developer's licenses.

    Scenario: Combinating compatible licenses
        Given I run local executable "licc" with arguments "bsd gpl"
        Then it should exit successfully
        Then I should see
        """
        BSD, GNU GPL 2.0
        Permits: DerivativeWorks, Distribution, Reproduction
        Requires: Copyleft, Notice, SourceCode
        Prohibits: ---
        """

    Scenario: Combinating non-compatible licenses
        Given I run local executable "licc" with arguments "gpl by-sa"
        Then it should not exit successfully
