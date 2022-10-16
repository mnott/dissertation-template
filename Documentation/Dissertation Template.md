This dissertation template builds on an earlier development that I had built for LaTeX: [TeXDown](https://github.com/mnott/texdown). The idea there is to create a parser that converts markdown into the most commonly used LaTeX commands. TeXDown was written for [Scrivener](https://www.literatureandlatte.com/scrivener/overview), a tool commonly used by authors writing novels and such. I liked the approach of a "Zettelkasten" and wrote a great deal of papers with it, routing them through my TeXDown, then through LaTeX, to get my output documents.

Yet Scrivener being very Mac centric and more so proprietory, I looked for another solution. Enter Obsidian. It can do everything that Scrivener can do, and so much more. The only thing I had to do is to rewrite my LaTeX make scripts, and my TeXDown along with it, to get Obsidian to do what I was doing with Scrivener.

This dissertation template is the result of this work. It allows you to mostly entirely focus on the content that you are writing, while maintaining the entire liberty of writing LaTeX command should you so want.

It uses YAML to describe common things in the document that you most likely want to write each time, and it uses a parser similar to that of TeXDown to preprocess Markdown into the most common LaTeX commands. The parser is of course extensible, so you can add your own functionality on the fly.

It comes with a command shell that wraps all things I commonly need, like choosing which document I am working on, duplicating / removing documents, creating maps of contents and removing them, running LaTeX, and even wrapping the most common Git commands on your document tree.

Having said all of this, I'm going to describe a simple installation. It runs under MacOS, Windows, and there's no reason why it shouldn't run under Linux; in fact, it is just a bash script and some Perl.

Have fun with it, and bear with me while I'm adding more and more documentation.