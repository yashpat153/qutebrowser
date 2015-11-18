Feature: Various utility commands.

    ## :set-cmd-text

    Scenario: :set-cmd-text and :command-accept
        When I run :set-cmd-text :message-info "Hello World"
        And I run :command-accept
        Then the message "Hello World" should be shown.

    Scenario: :set-cmd-text with two commands
        When I run :set-cmd-text :message-info test ;; message-error error
        And I run :command-accept
        Then the message "test" should be shown.
        And the error "error" should be shown.

    Scenario: :set-cmd-text with URL replacement
        When I open data/hello.txt
        When I run :set-cmd-text :message-info >{url}<
        And I run :command-accept
        Then the message ">http://localhost:*/hello.txt<" should be shown.

    Scenario: :set-cmd-text with -s and -a
        When I run :set-cmd-text -s :message-info "foo
        And I run :set-cmd-text -a bar"
        And I run :command-accept
        Then the message "foo bar" should be shown.

    Scenario: :set-cmd-text with -a but without text
        When I run :set-cmd-text -a foo
        Then the error "No current text!" should be shown.

    Scenario: :set-cmd-text with invalid command
        When I run :set-cmd-text foo
        Then the error "Invalid command text 'foo'." should be shown.

    ## :message-*

    Scenario: :message-error
        When I run :message-error "Hello World"
        Then the error "Hello World" should be shown.

    Scenario: :message-info
        When I run :message-info "Hello World"
        Then the message "Hello World" should be shown.

    Scenario: :message-warning
        When I run :message-warning "Hello World"
        Then the warning "Hello World" should be shown.

    ## :jseval

    Scenario: :jseval
        When I set general -> log-javascript-console to true
        And I run :jseval console.log("Hello from JS!");
        And I wait for "[:0] Hello from JS!" in the log
        Then the message "No output or error" should be shown.

    Scenario: :jseval without logging
        When I set general -> log-javascript-console to false
        And I run :jseval console.log("Hello from JS!");
        Then the message "No output or error" should be shown.
        And "[:0] Hello from JS!" should not be logged

    Scenario: :jseval with --quiet
        When I set general -> log-javascript-console to true
        And I run :jseval --quiet console.log("Hello from JS!");
        And I wait for "[:0] Hello from JS!" in the log
        Then "No output or error" should not be logged

    Scenario: :jseval with a value
        When I run :jseval "foo"
        Then the message "foo" should be shown.

    Scenario: :jseval with a long, truncated value
        When I run :jseval Array(5002).join("x")
        Then the message "x* [...trimmed...]" should be shown.

    # :debug-webaction

    Scenario: :debug-webaction with valid value
        Given I open data/backforward/1.txt
        When I open data/backforward/2.txt
        And I run :tab-only
        And I run :debug-webaction Back
        And I wait until data/backforward/1.txt is loaded
        Then the session should look like:
            windows:
            - tabs:
              - history:
                - active: true
                  url: http://localhost:*/data/backforward/1.txt
                - url: http://localhost:*/data/backforward/2.txt

    Scenario: :debug-webaction with invalid value
        When I open data/hello.txt
        And I run :debug-webaction blah
        Then the error "blah is not a valid web action!" should be shown.

    Scenario: :debug-webaction with non-webaction member
        When I open data/hello.txt
        And I run :debug-webaction PermissionUnknown
        Then the error "PermissionUnknown is not a valid web action!" should be shown.

    # :inspect

    Scenario: Inspector without developer extras
        When I set general -> developer-extras to false
        And I run :inspector
        Then the error "Please enable developer-extras before using the webinspector!" should be shown.

    Scenario: Inspector smoke test
        When I set general -> developer-extras to true
        And I run :inspector
        And I run :inspector
        Then no crash should happen
