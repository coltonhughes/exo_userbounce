#!/usr/bin/python
# -*- coding: utf-8 -*-


# Copyright 2020 Colton Hughes <colton.hughes@firemon.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


ANSIBLE_METADATA = {'status': ['stableinterface'],
                    'supported_by': 'community',
                    'version': '1.0'}

DOCUMENTATION = '''
---
module: exo_userbounce
version_added: "2.9.10"
short_description: Adds user to an ExchangeOnline transport rule
description:
     - The Module adds a user/email to an existing Exchange Online Transport Rule
options:
  rule_name:
    description:
      - Name of the Exchange Online Transport Rule (Case sensitive)
    required: true
    default: null
    aliases: []
  user_email:
    description:
      - Email to be added to the rule above.
    required: true
    default: null
    aliases: []
  mode:
    description:
      - Method of adding a recipient
    required: true
    default: append
    choices:
      - append
      - override
    aliases: []
  condition:
    description:
      - Type of condition to apply to rule
    required: true
    default: sentTo
    choices:
      - sentTo
      - from
    aliases: []
  exo_username:
    description:
      - Username with permission to modify Exchange Transport Rules
    required: true
    default: null
    aliases: []
  exo_password:
    description:
      - Password matching username with permission to modify Exchange Transport Rules
    required: true
    default: null
    aliases: []
author: "Colton Hughes <colton.hughes@firemon.com>"
'''

EXAMPLES = '''
- name: Add 'john.do@example.com' to an Exchange Online Rule
  exo_userbounce:
    rule_name: "Test Rule to disable email for user"
    user_email: john.doe@example.com
    mode: append
    condition: sentTo
    exo_username: globaladmin@domain.onmicrosoft.com
    exo_password: P@ssw0rd!
'''
RETURN = '''
existing_recipients:
  description: original recipients on transport rule defined
  returned: always
  type: list
  sample:
    - john.doe@example.com
    - bob.joe@example.com
new_recipients:
  description: new recipients including the existing
  returned: changed
  type: list
  sample:
    - john.doe@example.com
'''
