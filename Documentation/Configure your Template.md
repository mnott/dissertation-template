# Configure your Template

Once you have [cloned your template](Clone%20your%20own%20Template.md), you can configure it. Look into your context's folder under `Content`. Typically you'll see this structure:

1. `template`: A configuration file with which you can control the behavior of your LaTeX document. This is where you can configure your document title, whether you want have e.g.  a table of content or not, etc.
2. `include`: A configuration file where you can list the top level chapters that you want to run; you can comment lines out with a hashmark (`#`); this file allows you to just run e.g. the chapter that you are currently working on, through LaTeX.
3. `fig`: A directory where you'd put your images that you want to include in your document.
4. `ZZ - Appendix`: These are sample files for static appendices. They give you place for adding a static glossary and additional appendix content. Even if you don't need them, leave them there.
5. `Chapter 0` etc.: Actual content as listed by `include`; you can add more as you like; the LaTeX shell will parse them in alphabetical order.

