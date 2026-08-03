# Implementation Plan

## Fix Broken Links Across the Site

The project uses clean URLs (`cleanUrls: true`) and many anchor tags reference tools without the proper `tools/` directory prefix (e.g., `href="json-formatter"`). This causes 404 errors because the actual files live at `tools/<tool>/<tool>.html`. We will:

1. **Identify all HTML files** in the repository.
2. **Parse each file** and replace any `href` values that:
   - Do not start with `http`, `https`, `#`, `/`, or `tools/`.
   - Match a known tool slug (e.g., `json-formatter`, `meta-tag-generator`).
   - Replace them with `tools/<slug>/<slug>.html` (or the appropriate path for the tool when a custom folder structure is used).
3. **Update related assets** (e.g., `canonical` links, `og:url`, `schema.org` URLs) to the new correct URLs.
4. **Run the existing renaming VBS script** to ensure brand names are already updated.
5. **Add a single notification** after the script finishes (already done).
6. **Verify** by linting the HTML and optionally running a local build.

## User Review Required

> [!IMPORTANT]
> This change will modify *all* HTML files in the project, updating dozens of `href` attributes. Please confirm that this approach is acceptable.

## Open Questions

- Are there any custom URLs that intentionally point outside the `tools/` folder (e.g., external docs) that should be excluded?
- Should we also update `src` attributes for images if they follow the same pattern?

## Proposed Changes

### [MODIFY] `c:/Users/as2152/Documents/GitHub/free-online-seo-tools/fix_links.vbs`
- A new VBS script that recursively processes all `.html` files, applies the href replacements described above, and writes the changes back.
- The script will output a summary of files changed.

### [MODIFY] `c:/Users/as2152/Documents/GitHub/free-online-seo-tools/rename_to_asegya_toolkit.vbs`
- No changes needed; it already updates brand names.

## Verification Plan

- Run the new VBS script locally.
- Open a few representative pages in a browser to ensure links resolve.
- Use `grep` to confirm no remaining stray `href="[tool]"` patterns.

---

*Please review the plan and approve or provide feedback.*
