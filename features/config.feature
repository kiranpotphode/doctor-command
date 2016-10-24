Feature: Configure the Doctor

  Scenario: Error when config file doesn't exist
    Given an empty directory

    When I try `wp doctor list --config=foo.yml`
    Then STDERR should be:
      """
      Error: Invalid configuration file.
      """

  Scenario: Error when a check class doesn't exist
    Given an empty directory
    And a config.yml file:
      """
      undefined-class:
        class: Class_Undefined
      """

    When I try `wp doctor check --all --config=config.yml`
    Then STDERR should be:
      """
      Error: Class 'Class_Undefined' for check 'undefined-class' doesn't exist. Verify check registration.
      """

  Scenario: Error when a check class doesn't extend our base class
    Given an empty directory
    And a config.yml file:
      """
      invalid-class:
        class: WP_CLI
      """

    When I try `wp doctor check --all --config=config.yml`
    Then STDERR should be:
      """
      Error: Class 'WP_CLI' for check 'invalid-class' needs to extend Check base class. Verify check registration.
      """

  Scenario: Error when an invalid check name is provided
    Given an empty directory
    And a config.yml file:
      """
      check space:
        class: runcommand\Doctor\Checks\Constant_Definition
      """

    When I try `wp doctor check --all --config=config.yml`
    Then STDERR should be:
      """
      Error: Check name 'check space' is invalid. Verify check registration.
      """

  Scenario: Error when a check is missing its 'check' or 'class'
    Given an empty directory
    And a config.yml file:
      """
      constant-custom:
        constant: Constant_Definition
        options:
          constant: CUSTOM
          defined: true
      """

    When I try `wp doctor list --config=config.yml`
    Then STDERR should be:
      """
      Error: Check 'constant-custom' is missing 'class' or 'check'. Verify check registration.
      """

  Scenario: Error when a check has been provided an unsupported option
    Given an empty directory
    And a config.yml file:
      """
      constant-invalid-option:
        check: Constant_Definition
        options:
          constant_name: CUSTOM
          defined: true
      """

    When I try `wp doctor list --config=config.yml`
    Then STDERR should be:
      """
      Error: Cannot set invalid property 'constant_name'.
      """

  Scenario: Support inheriting another config file
    Given an empty directory
    And a first-config.yml file:
      """
      constant-wp-debug:
        check: Constant_Definition
        options:
          constant: WP_DEBUG
          falsy: true
      """
    And a second-config.yml file:
      """
      _:
        inherit: first-config.yml
      constant-savequeries:
        check: Constant_Definition
        options:
          constant: SAVEQUERIES
          falsy: true
      """

    When I run `wp doctor list --format=count --config=first-config.yml`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp doctor list --format=count --config=second-config.yml`
    Then STDOUT should be:
      """
      2
      """

  Scenario: Support inheriting the default doctor.yml
    Given an empty directory
    And a first-config.yml file:
      """
      _:
        inherit: default
      constant-custom:
        check: Constant_Definition
        options:
          constant: CUSTOM
          defined: true
      """

    When I run `wp doctor list --config=first-config.yml --fields=name`
    Then STDOUT should be a table containing rows:
      | name                        |
      | constant-custom             |
      | constant-savequeries-falsy  |

  Scenario: Permit checks to be skipped when inheriting
    Given an empty directory
    And a skipped-checks.yml file:
      """
      _:
        inherit: default
        skipped_checks:
          - constant-savequeries-falsy
      """

    When I run `wp doctor list --fields=name`
    Then STDOUT should contain:
      """
      constant-savequeries-falsy
      """

    When I run `wp doctor list --config=skipped-checks.yml --fields=name`
    Then STDOUT should not contain:
      """
      constant-savequeries-falsy
      """
