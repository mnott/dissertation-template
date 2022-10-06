```latex
%=====================================================
% Additional Appendix Content
%
% For a Book, you'd use Chapter level; else, you'd
% use section level; excluding the sections from the
% TOC using *. Here is a plain LaTeX example, but you
% can also use Markdown.
%=====================================================

\ifthenelse{\equal{\doctype}{book}}{
  \chapter{Some HeaderA}
}{
  \section*{Some HeaderA}
}
\label{sec:some_headerA}

%-----------------------------------------------------
% Content follows below.
%-----------------------------------------------------

```

