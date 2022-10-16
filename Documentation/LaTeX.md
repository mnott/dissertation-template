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