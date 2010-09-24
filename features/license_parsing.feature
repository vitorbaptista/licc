Feature: Parsing of license files
  As a developer
  I want to know which requirements, prohibitions and permissions a license gives me
  So I can know my rights and duties.

    Scenario: Analyzing a known license
        Given I run local executable "licc" with arguments "gpl3"
        Then I should see
        """
        GNU GPL 3.0
        Permits: DerivativeWorks, Distribution, Reproduction
        Requires: Copyleft, Notice, SourceCode
        Prohibits: ---
        """

    Scenario: Analyzing an unknown local license
        Given I run local executable "licc" with arguments "../lib/licc/licenses/gpl3.rdf"
        Then I should see
        """
        GNU GPL 3.0
        Permits: DerivativeWorks, Distribution, Reproduction
        Requires: Copyleft, Notice, SourceCode
        Prohibits: ---
        """
