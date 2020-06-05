#!/usr/bin/env python3.8

#
# Convert content.txt to index.html
#

import logging
import os
import sys

from logging import warning as warn, error as err
from pprint import pprint
from typing import Optional
from re import match

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def bail(*args, **kwargs):
    err(*args, **kwargs)
    sys.exit(0)

fname = 'content.txt'
fout  = 'index.html'

class Content:
    def __init__(self):
        self.title = None
        self.rules = []
        self.refs = {}  # ident : (name, url)

class Rule:
    def __init__(self, header: str, num: int):
        self.header = header
        self.num = num
        self.infos = []

    def html(self) -> str:
        html = f'''
            <section class="mb-5">
                <h2 class="w-100 border border-top-0 border-left-0 border-right-0" data-toggle="collapse" data-target="#rule{self.num}-content">
                    <small class="text-muted noselect">
                        Rule {self.num}
                    </small>
                    <br>
                    <span class="clickable">
                        {self.header.strip()}
                    </span>
                </h2>
                <div id="rule{self.num}-content" class="collapse">
                    <ul class="list-group list-group-flush">
        '''
        for info in self.infos:
            html += info.html()
        html += '''
                    </ul>
                </div>
            </section>
        '''
        return html

class Info:
    def __init__(self, txt: str):
        self.txt = txt
        self.detail = None

    def html(self) -> str:
        if self.detail is None:
            return f'''
                <li class="list-group-item">
                    {self.txt.strip()}
                </li>
            '''
        else:
            return f'''
                <li class="list-group-item">
                    {self.txt}
                    <div class="alert mb-0 text-secondary">
                        <table>
                            <tr>
                                <td>
                                    <i class="fas fa-question-circle mr-3"></i>
                                </td>
                                <td>
                                    {self.detail.strip()}
                                </td>
                            </tr>
                        </table>
                    </div>
                </li>
            '''

c = Content()

# First iteration
# 
# Fill content object
# Don't evaluate links until second iteration
rulecnt = 0
for (i, line) in enumerate(open(fname)):
    line = line.rstrip()
    if len(line) < 2:
        continue
    first, txt = line[0], line[1:]

    try:
        if first == '#':
            assert c.title is None, f'line {i+1}: multiple titles'
            c.title = txt

        # Rule header
        elif first == '=':
            rulecnt += 1
            c.rules.append(Rule(txt, rulecnt))

        # Rule info
        elif first == '-':
            assert c.rules, 'info outside rule'
            rule = c.rules[-1]
            rule.infos.append(Info(txt))

        # Info detail
        elif first == '?':
            assert c.rules, 'detail outside rule'
            rule = c.rules[-1]
            assert rule.infos, 'detail outside rule info'
            assert rule.infos[-1].detail is None, 'multiple details for rule info'
            rule.infos[-1].detail = txt

        elif first == '[':
            assert match(r'\[.+\].+\|.+', line), 'malformed reference'
            idx = line.index(']') + 1
            ident = line[:idx]
            vals = line[idx:].split('|', maxsplit=1)
            c.refs[ident] = vals

    except AssertionError as e:
        bail(f'line {i+1}: {e}')

assert c.title is not None, 'missing page title'

# Second iteration
#
# Evaluate links
for (i, (ident, (name, url))) in enumerate(c.refs.items()):
    html = f'<small><sup><a href="{url.strip()}" target="_blank">[{i+1}]</a></sup></small>'
    for rule in c.rules:
        if ident in rule.header:
            rule.header = rule.header.replace(ident, html)
        for info in rule.infos:
            if ident in info.txt:
                info.txt = info.txt.replace(ident, html)
            if info.detail and ident in info.detail:
                info.detail = info.detail.replace(ident, html)

# HTML head
html = '''
  <!DOCTYPE html>
  <html>

  <head>
    <meta charset="UTF-8">
    <title>MH</title>

    <!-- Favicon -->
    <link rel="shortcut icon" type="image/png" href="assets/icon.png" />

    <link href="assets/fontawesome-free-5.13.0-web/css/all.css" rel="stylesheet">
    <link href="assets/bootstrap-4.5.0-dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- <link href="assets/boostrap-darkly.min.css" rel="stylesheet"> -->
    <script src="assets/jquery-3.5.1.min.js"></script>
    <script src="assets/bootstrap-4.5.0-dist/js/bootstrap.bundle.min.js"></script> <!-- includes Popper -->

    <style>
      .clickable {
        cursor: pointer;
      }

      .noselect {
        user-select: none;
      }

      @font-face {
        font-family: campton;
        src: url("assets/light.otf") format("opentype");
      }

      @font-face {
        font-family: campton;
        font-weight: bold;
        src: url("assets/bold.otf") format("opentype");
      }

      * {
        font-family: campton;
      }
    </style>
  </head>
'''

# Page title
html += f'''
  <body>
  <header class="jumbotron jumbotron-fluid">
    <div class="container">
      <h1 class="display-3">{c.title.strip()}</h1>
    </div>
  </header>
  <main class="container">
'''

# Third iteration
#
# Create html
for rule in c.rules:
    html += rule.html()

# References
html += '''
    <section class="mb-5" id="references">
      <h2>References</h2>
      <ol>
'''
for (name, url) in c.refs.values():
    html += f'''
        <li>
            <a href="{url.strip()}">{name.strip()}</a>
        </li>
    '''

# End of page
html += '''
      </ol>
    </section>

  </main>

  <footer class="jumbotron jumbotron-fluid">
    <div class="container text-center mt-4">
      <p>Magnus Aa. Hirth</p>
    </div>
  </footer>

</body>

</html>
'''

open(fout, 'w').write(html)
