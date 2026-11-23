-- Convert SVG images to PDF before pandoc sees them.
--
-- pandoc 2 turned an SVG into PDF itself when the output was a PDF (it called
-- rsvg-convert behind our back, which is why the old pdf runs needed it on
-- PATH).  pandoc 3 instead writes \includesvg{...} and expects the LaTeX `svg'
-- package, which in turn wants Inkscape -- a dependency this pipeline does not
-- have and would rather not grow.
--
-- So, for pandoc 3 only (bin/gen-pdf adds this filter when `pandoc --version'
-- says 3 or later), every SVG image is rendered to a PDF in a temporary
-- directory and the image source is rewritten to it; pandoc then writes a plain
-- \includegraphics.  The directory is per run and is left to the temporary
-- directory cleaner: the PDFs are inputs to this render, not output.

local outdir = nil

local function svg_outdir()
  if outdir == nil then
    local base = os.getenv("TMPDIR") or "/tmp"
    -- A name per run and per process: pandoc renders the same paper more than
    -- once in a session (LaTeX passes) but each pandoc invocation is its own
    -- process, so the seconds plus the address of this table is enough.
    outdir = string.format("%s/bhxiv-svg-%d-%d", base, os.time(), math.random(1, 1e6))
    pandoc.system.make_directory(outdir, true)
  end
  return outdir
end

function Image(image)
  local src = image.src or ""
  if src:lower():match("%.svg$") then
    local out = string.format("%s/%s.pdf", svg_outdir(), pandoc.sha1(src))
    local ok, err = pcall(pandoc.pipe, "rsvg-convert", {"-f", "pdf", "-o", out, src}, "")
    if not ok then
      io.stderr:write(string.format(
        "svg-to-pdf: cannot convert %s with rsvg-convert (%s)\n", src, tostring(err)))
      os.exit(1)
    end
    image.src = out
  end
  return image
end
