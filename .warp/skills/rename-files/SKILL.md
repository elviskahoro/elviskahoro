---
name: rename-files
description: Rename files to follow a consistent naming convention. Use this skill whenever the user wants to rename files to be lowercase with underscores replacing spaces, hyphens as delimiters between concepts, no leading numbers, and no spaces. Examples of the target format: todo-name_of_spec-version_of_spec.md, project-component_name-feature_description.py. Always show a preview of the rename mapping before executing changes.
compatibility: null
---

# File Renaming Skill

This skill renames files to follow a consistent, clean naming convention designed for filesystem safety and readability.

## Naming convention enforced

- **Lowercase only**: all characters in filename converted to lowercase
- **No spaces**: spaces replaced with underscores
- **Hyphens as delimiters**: hyphens represent boundaries between concepts/logical sections
- **Underscores within concepts**: underscores connect words within a concept
- **No leading numbers**: filenames never start with a digit
- **Preserve extensions**: file extensions (`.md`, `.js`, `.py`, etc.) remain unchanged
- **Remove special characters**: characters like `!`, `@`, `#`, etc. removed or replaced with hyphens/underscores as appropriate

## Examples of the target format

- `todo-name_of_spec-version_of_spec.md` (concept hyphens: todo, name_of_spec, version_of_spec)
- `project-component_name-feature_description.py`
- `user-auth_service-v2.js`
- `data-processing_script-for_csv_imports.sh`

## Workflow

1. **Understand the user's intent**: which files to rename, or if applying the convention to all files in a directory
2. **Use bash commands** (`ls`, `sed`, `tr`, etc.) to generate a list of old → new filename mappings
3. **Show a preview table** of the planned renames
4. **Check for conflicts** (two files mapping to same new name)
5. **Get explicit confirmation** before proceeding
6. **Execute the renames** using `mv` commands and report results

## Implementation approach

- Use bash/CLI tools (`tr`, `sed`, `mv`, `ls`) to generate and execute renames
- Show the user a preview of all renames before proceeding
- Generate individual `mv` commands for user review
- Execute renames and provide a summary
- Handle special cases (leading numbers, conflicts, existing files) with clear prompts

## Bash command examples

### Generate rename mappings with preview
Show all files in a directory with their planned new names:
```bash
ls -1 | while read file; do
  newname=$(echo "$file" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g')
  echo "$file → $newname"
done
```

### Handle spaces and convert to lowercase
```bash
for file in *; do
  newname=$(echo "$file" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]')
  [ "$file" != "$newname" ] && echo "mv \"$file\" \"$newname\""
done
```

### Remove special characters
```bash
for file in *; do
  newname=$(echo "$file" | sed 's/[^a-zA-Z0-9._-]//g' | tr '[:upper:]' '[:lower:]')
  [ "$file" != "$newname" ] && echo "mv \"$file\" \"$newname\""
done
```

### Handle leading numbers (move to end)
```bash
for file in *; do
  # Extract extension
  ext="${file##*.}"
  name="${file%.*}"
  
  # Check for leading number
  if [[ "$name" =~ ^[0-9] ]]; then
    # Move number to end of filename
    newname=$(echo "$name" | sed 's/^\([0-9]*\)\(.*\)/\2_\1/' | tr '[:upper:]' '[:lower:]')."$ext"
  else
    newname=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')."$ext"
  fi
  
  [ "$file" != "$newname" ] && echo "mv \"$file\" \"$newname\""
done
```

### Check for conflicts (duplicate target names)
```bash
for file in *; do
  newname=$(echo "$file" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g')
  echo "$newname"
done | sort | uniq -d
```

### Execute renames from a mapping (safe approach)
First create and review a mapping file, then execute:
```bash
# Generate mapping file
for file in *; do
  newname=$(echo "$file" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g')
  [ "$file" != "$newname" ] && echo "$file|$newname"
done > rename_plan.txt

# Show preview
cat rename_plan.txt

# Execute (after user confirmation)
cat rename_plan.txt | while IFS='|' read -r old new; do
  if [ -f "$old" ]; then
    mv "$old" "$new" && echo "✓ $old → $new" || echo "✗ Failed: $old"
  fi
done
```

### Batch rename with pattern matching
Rename only certain files (e.g., PDFs):
```bash
for file in *.pdf; do
  [ -f "$file" ] || continue
  newname=$(echo "$file" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]')
  [ "$file" != "$newname" ] && mv "$file" "$newname"
done
```

## Edge cases

- **Files starting with numbers**: Ask user if they want to prepend a prefix (e.g., `num_`) or move the number to after the first concept
- **Multiple dots in filename**: Only the last dot and extension are preserved; treat earlier dots as separators
- **Existing file with target name**: Warn and ask to skip, overwrite, or append a suffix like `_old`
- **No changes needed**: Skip files that already match the convention
- **Empty filename after conversion**: Flag as an error (shouldn't happen with valid input)

## User interaction

Always:
- Show a preview table before making any changes
- Use clear formatting: `old_name.ext → new_name.ext`
- Ask explicit yes/no confirmation before executing
- Provide a summary after execution showing counts (renamed, skipped, failed)
