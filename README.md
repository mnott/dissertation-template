# dissertation-template

A LaTeX Template for Dissertations that works well with Obsidian.

# Description

## Enter LaTeX

When you are writing any document of length, LaTeX is an excellent choice. It will take care of your formatting needs, references, etc. To put it in another way, if you've ever struggled with your common word processor when you had to turn in a paper, LaTeX would have made it much more easy for you.

At the same time, LaTeX may appear as being particularly difficult. As opposed to a "WYSIWYG" - what you see is what you get - approach, where you immediately see what you are going to ideally get, LaTeX is a "WYSIWIR" - what you see is what is relevant - approach: When you do it right, you never have to focus on the design of the text, but you can fully concentrate on the content itself. LaTeX is a document description programming language; in other words, you "program" your document.

When I started with LaTeX, about 25 years ago, you'd typically see a document containing things like this:

```LaTeX
  \begin{document}
  \section{This is a section header}
  Some text\label{some-label}
  \begin{itemize}
  \item An item
  \item Another item
  \end{itemize}

  See page \pageref{some-label}
  \end{document}
```

As you can imagine, while this relieves you of all of the layouting and referencing that is normally going on, it adds to the picture a potentially large number, even if not variety, of commands that again can distract you from the actual content that you are writing.

In normal texts, these markup commands are not overly many. You'd typically see sections, subsections, itemizes, etc. Yet, you'd still "see" them, and if we want to entirely concentrate on the content, there should be a way to hide as much as possible of them.

## Enter Markdown

Essentially, LaTeX is a markup language. It predates HTML by at least 20 years. Hence, it might look a bit clumsy. At the same time, every text that I wrote as a young student of Physics, over 25 years ago, will still come out precisely the same way as when I wrote it. This consistency is one of the many advantages of LaTeX.

But today, the world has moved on and new markup languages have arrived; the most important of them probably Markdown, and the most important editor for them, [Obsidian](https://obsidian.md).

In Markdown, you can write similar things like in the above example with simply something like

```markdown
  # This is a section header
  
  Some text ^some-label
  
  - An item
  - Another item

  See page (Well, Markdown does not have pages...)
```

This is significantly less clutter. At the same time, as you can see from the last line, since Markdown is not a page description language, but rather something to describe a structure, it does not go all the way to provide the necessary information to a page formatter like LaTeX.

## Enter Pandoc

Pandoc strives to close that gap by allowing you to pre-process your Markdown files. It is a very powerful tool that can achieve everything that I am doing with this dissertation template (because it uses a programming language, lua, to implement missing functionality). I found it somewhat hard for what I wanted to do, and use it only for some basic processing.

## Enter the Dissertation Template

This dissertation template builds on an earlier development that I had built for LaTeX: [TeXDown](https://github.com/mnott/texdown). The idea there is to create a parser that converts markdown into the most commonly used LaTeX commands. TeXDown was written for [Scrivener](https://www.literatureandlatte.com/scrivener/overview), a tool commonly used by authors writing novels and such. I liked the approach of a "Zettelkasten" and wrote a great deal of papers with it, routing them through my TeXDown, then through LaTeX, to get my output documents.

Yet Scrivener being very Mac centric and more so proprietory, I looked for another solution. Enter Obsidian. It can do everything that Scrivener can do, and so much more. The only thing I had to do is to rewrite my LaTeX make scripts, and my TeXDown along with it, to get Obsidian to do what I was doing with Scrivener.

This dissertation template is the result of this work. It allows you to mostly entirely focus on the content that you are writing, while maintaining the entire liberty of writing LaTeX command should you so want.

It uses YAML to describe common things in the document that you most likely want to write each time, and it uses a parser similar to that of TeXDown to preprocess Markdown into the most common LaTeX commands. The parser is of course extensible, so you can add your own functionality on the fly.

It comes with a command shell that wraps all things I commonly need, like choosing which document I am working on, duplicating / removing documents, creating maps of contents and removing them, running LaTeX, and even wrapping the most common Git commands on your document tree.

Having said all of this, I'm going to describe a simple installation. It runs under MacOS, Windows, and there's no reason why it shouldn't run under Linux; in fact, it is just a bash script and some Perl.

Have fun with it, and bear with me while I'm adding more and more documentation.

# Installation

The installation is described [here](Documentation/README.md).

See [Initial Steps](Documentation/Initial%20Steps.md) for the initial steps you need to do.


# Basic Usage

See [here](Documentation/Basic%20Usage.md) for some basic usage.

# Donation

Are you enjoying this project ? 👋

You can express your ❤️ by buying me a coffee ☕️ to keep this project maintained and stay alive, I would ❤️ to dedicate more time and effort on it!

However you could just sharing this project with your friends, that would help me a lot as well! 👊

Thanks for your support in advance! ☀️

<a href="https://www.buymeacoffee.com/mnott" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>


