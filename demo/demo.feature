Feature: User login functionality

  As a registered user
  I want to log into my account
  So that I can access my personalized dashboard

  Scenario Outline: Login attempt with different credentials
    Given the user is on the login page
    When the user enters "<username>" and "<password>"
    And clicks the login button
    Then the user should see "<message>"

    @login
    @regression
    Examples:
      | username       | password       | message                                |
      | valid_user     | valid_pass     | Welcome to your dashboard, valid_user! |
      | invalid_user   | valid_pass     | Invalid username or password           |
      | valid_user     | invalid_pass   | Invalid username or password           |
      | empty_user     | empty_pass     | Both fields are required               |
      | valid_user     |                | Password cannot be empty               |

