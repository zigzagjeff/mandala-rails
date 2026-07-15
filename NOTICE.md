# Third-party notices

Mandala was developed with 37signals' Fizzy
(https://github.com/basecamp/fizzy) as a reference for Rails structure and
conventions. Most of Mandala is original work; the following portion is a
direct adaptation of Fizzy source and is covered by the notice reproduced
below, per condition 1 of Fizzy's O'Saasy License:

- `app/models/concerns/eventable.rb` — adapted from Fizzy's
  `app/models/concerns/eventable.rb` (domain renamed from board to chart).

Fizzy's design conventions also informed several other files
(authentication, session, and export patterns), but those were rebuilt for
Mandala's domain rather than copied.

---

## O'Saasy License Agreement (37signals Fizzy)

Copyright © 2025, 37signals LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
2. No licensee or downstream recipient may use the Software (including any modified or derivative versions) to directly compete with the original Licensor by offering it to third parties as a hosted, managed, or Software-as-a-Service (SaaS) product or cloud service where the primary value of the service is the functionality of the Software itself.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
