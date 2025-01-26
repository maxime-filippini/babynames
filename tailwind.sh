#!/bin/bash

OUTPUT_FILE="output.html"
> "$OUTPUT_FILE"

echo "Getting tailwind classes from gleam files..."

find . -type f -name "*.gleam" -not -path "*/build/*" | while read -r GLEAM_FILE
do
  # Use Perl in "slurp" mode (-0777) to read entire file content at once
  # and capture all occurrences of class("...") even if they span multiple lines.
  perl -0777 -ne '
    while (/class\s*\(\s*"([^"]*)"/sg) {
      # Print only the <div> element
      print "<div class=\"$1\"></div>\n";
    }
  ' "$GLEAM_FILE" >> "$OUTPUT_FILE"
done

echo "Running tailwind..."
npx @tailwindcss/cli -i ./priv/static/input.css -o ./priv/static/styles.css

rm $OUTPUT_FILE