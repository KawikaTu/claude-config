# convert-doc

Convert documents to Markdown using essay_miyaki.

## Instructions

You convert documents to Markdown format using the `essay_miyaki` CLI tool located at `${ESSAY_MIYAKI_DIR:-$HOME/to_markdown}`.

### How to convert

Run conversions from the project directory using `uv run`:

```bash
cd ${ESSAY_MIYAKI_DIR:-$HOME/to_markdown} && uv run essay_miyaki convert <FILES_OR_DIRS> [OPTIONS]
```

### Supported formats

PDF, DOCX, PPTX, XLSX, HTML, HTM, TXT, CSV, MD, JSON, JPEG, JPG, TIFF, BMP, WEBP, PNG

### Common options

- `-o, --output DIR` - Output directory (default: `./converted_files`)
- `-v, --verbose` - Verbose output
- `-q, --quiet` - Suppress output except errors
- `--dry-run` - Show what would be converted
- `--workers N` - Number of parallel workers
- `--list-duplicates` - List duplicate files without converting
- `--no-recursive` - Don't recurse into subdirectories

### Other commands

- `uv run essay_miyaki stats [-o DIR]` - Show conversion statistics
- `uv run essay_miyaki batch` - Run batch workflow (processes `unprocessed_files/` directory)
- `uv run essay_miyaki version` - Show version

### Behavior

1. Use absolute paths for input files when they are outside the project directory.
2. Default output goes to `./converted_files/` relative to CWD. Specify `-o` to control output location.
3. The tool automatically deduplicates files using BLAKE3 hashing.
4. After conversion, read the output markdown file and present it to the user or confirm success.
5. For single file conversions, use this skill directly. For large batch operations (10+ files or full directories), delegate to the `doc-converter` agent instead.

### Examples

```bash
# Single file
cd ${ESSAY_MIYAKI_DIR:-$HOME/to_markdown} && uv run essay_miyaki convert /path/to/document.pdf -o /path/to/output

# Multiple files
cd ${ESSAY_MIYAKI_DIR:-$HOME/to_markdown} && uv run essay_miyaki convert file1.pdf file2.docx -o ./output

# Dry run
cd ${ESSAY_MIYAKI_DIR:-$HOME/to_markdown} && uv run essay_miyaki convert /path/to/docs/ --dry-run
```

## Allowed tools

- Bash(cd ${ESSAY_MIYAKI_DIR:-$HOME/to_markdown} && uv run essay_miyaki *)
- Read
- Glob
