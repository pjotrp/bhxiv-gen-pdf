-- Typeset runs of CJK characters, which pdflatex cannot otherwise handle.
--
-- A BioHackrXiv paper may quote a place name in Japanese ("Fukuoka (\u798F\u5CA1)"),
-- and pdflatex with inputenc stops at the first such character with
-- "Unicode character \u798F (U+798F) not set up for use with LaTeX".  The LaTeX
-- CJK package typesets them: this filter wraps each run of CJK characters in
-- \begin{CJK*}{UTF8}{ipxm} ... \end{CJK*}, and resources/biohackrxiv/
-- latex.template loads CJKutf8.
--
-- ipxm is IPAex Mincho, whose metrics come from texlive-ipaex-type1.  The
-- "min"/"goth" families that older examples use come from the cjk package's
-- contrib/wadalab directory, which TeX Live installs on its input path but
-- Guix's texlive-wadalab does not, so those silently typeset nothing.

local function is_cjk(cp)
  return (cp >= 0x2E80 and cp <= 0x9FFF)    -- radicals through CJK unified
      or (cp >= 0xF900 and cp <= 0xFAFF)    -- CJK compatibility ideographs
      or (cp >= 0x3040 and cp <= 0x30FF)    -- hiragana, katakana
      or (cp >= 0xFF00 and cp <= 0xFFEF)    -- fullwidth forms
end

local function wrap(text)
  return pandoc.RawInline("latex",
    "\\begin{CJK*}{UTF8}{ipxm}" .. text .. "\\end{CJK*}")
end

function Str(el)
  local out, cur, curcjk = pandoc.List(), "", nil
  for _, cp in utf8.codes(el.text) do
    local c = utf8.char(cp)
    local cj = is_cjk(cp)
    if curcjk == nil then curcjk = cj end
    if cj ~= curcjk then
      out:insert(curcjk and wrap(cur) or pandoc.Str(cur))
      cur, curcjk = "", cj
    end
    cur = cur .. c
  end
  out:insert(curcjk and wrap(cur) or pandoc.Str(cur))
  return out
end
