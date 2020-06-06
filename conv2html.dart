#!/usr/bin/env dart

// XXX: NOT WORKING

import 'dart:io';

const fname = 'content.txt';
const fout = 'index.html';

void check(bool pred, [String msg]) {
  if (!pred)
    throw AssertionError(msg ?? 'Check failed');
}

void main(List<String> args) {

  // First pass
  //
  // Read content and remove uninteresting lines
  var file = new File(fname);
  final lines = [
    for (var line in file.readAsLinesSync())
      if ( (line = line.trimRight()).length > 1 )
        line
  ];

  // Second pass
  //
  // Find title and references
  String title;
  var refs = <List<String>>[];
  var ref_re = new RegExp(r"\[.+\].+\|.+");

  for (var line in lines) {
    var first = line[0];

    if (first == '#') {
      check(title == null, 'multiple title definitions: $line');
      title = line.substring(1).trimLeft();
    } else if (first == '[') {
      check(ref_re.hasMatch(line), 'invalid reference: $line');
      refs.add(splitref(line));
    }
  }

  // Third pass
  //
  // Group rules and replace reference identifiers with hyperlinks
  var rules = <List<String>>[];
  for (var line in lines) {
    var first = line[0];

    if (first == '-' || first == '?')
      check(!rules.isEmpty, 'rule content outside rule: $line');
    else if (first != '=')
      continue;

    for (var ref in refs) {
      var html = '<small><sup><a href="${ref[2]}" target="_blank">[${ref[1]}]</a></sup></small>';
      line.replaceAll(ref[0], html);
    }

    if (first == '=')
      rules.add([line]);
    else
      rules.last.add(line);
  }

  // Fourth pass
  //
  // Create HTML output
  var html = '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="UTF-8">\n<title>MH</title>\n<!-- Favicon -->\n<link rel="shortcut icon" type="image/png" href="assets/icon.png" />\n<link href="assets/fontawesome-free-5.13.0-web/css/all.css" rel="stylesheet">\n<link href="assets/bootstrap-4.5.0-dist/css/bootstrap.min.css" rel="stylesheet">\n<!-- <link href="assets/boostrap-darkly.min.css" rel="stylesheet"> -->\n<script src="assets/jquery-3.5.1.min.js"></script>\n<script src="assets/bootstrap-4.5.0-dist/js/bootstrap.bundle.min.js"></script> <!-- includes Popper -->\n<style>\n.clickable {\ncursor: pointer;\n}\n.noselect {\nuser-select: none;\n}\n@font-face {\nfont-family: campton;\nsrc: url("assets/light.otf") format("opentype");\n}\n@font-face {\nfont-family: campton;\nfont-weight: bold;\nsrc: url("assets/bold.otf") format("opentype");\n}\n* {\nfont-family: campton;\n}\n</style>\n</head>\n<body>\n<header class="jumbotron jumbotron-fluid">\n<div class="container">\n<h1 class="display-3">$title</h1>\n</div>\n</header>\n<main class="container">\n';
  for (var rule in rules) {
    html += 
  }
}

List<String> splitref(int num, String str) {
  var idx = str.indexOf(']') + 1;
  var ident = str.substring(0, idx);
  var parts = str.substring(idx).split('|').map((e) => e.trim());
  check(parts.length == 2, 'invalid referenc: $str');
  return [ident, parts[0].trim(), parts[1].trim()];
}

/*******************************************************************************
 *                                                                             *
 * HTML helpers
 *                                                                             *
 *******************************************************************************/

String rule2html(List<String> rule) {
  var header = rule[0].substring(1).trimLeft();
  var infos = rule.length > 1 ? rule.sublist(1) : [];

  var html = """<section class="mb-5">
      <h2 class="w-100 border border-top-0 border-left-0 border-right-0" data-toggle="collapse" data-target="#rule$num-content">
        <small class="text-muted noselect">Rule $num</small>
        <br>
        <span class="clickable">$header</span>
      </h2>
      <div id="rule$num-content" class="collapse">
        <ul class="list-group list-group-flush">""";

  if (rule.length > 1) {
    html += '<li class="list-group-item">';

    for (var info in rule.sublist(1)) {
      var first = info[0];
      var txt = info.substring(1).trimLeft();

      if (first == '-')
        html += '</li>\n<li class="list-group-item">$txt';
      // else if (first == '?')
    }

    html += '</li>';
  }

  html += """</ul></div></section>""";
  return html;
}

String refs2html(List<List<String>> refs) {

}

String index(String title, String rules, String references) => """
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

<body>

  <header class="jumbotron jumbotron-fluid">
    <div class="container">
      <h1 class="display-3">$title</h1>
    </div>
  </header>

  <main class="container">
  $rules
  $references
  </main>

  <footer class="jumbotron jumbotron-fluid">
    <div class="container text-center mt-4">
      <p>Magnus Aa. Hirth</p>
    </div>
  </footer>

</body>

</html>
""";