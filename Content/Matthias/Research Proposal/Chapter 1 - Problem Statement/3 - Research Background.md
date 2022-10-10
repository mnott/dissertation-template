### Research Background

As part of this research, a pilot study was undertaken between December 2017 and April 2018, attempting to validate approaches answering what was the original research question:

```latex
\bigskip\begin{bulletpoint}
```
How to measure the Quality Improvement of the Ideas,
Teams, and the Program? ^rqori
```latex
\end{bulletpoint}\bigskip
```

This research was planned to be based on an evaluation of the original idea submissions of each cohort. As part of the pilot study, 1'177 idea submissions were evaluated using a k-Nearest Neighbor based, automated text clustering mechanism. The pilot study showed that the original research question, focusing on the teams' journey and based only on the initial submissions provides for limited utility of the research: While the investigated methods proved to be relatively accurate at predicting for a given submission whether it would be promoted to a later stage or not, the predictions were heavily biased toward the earlier stages of the program, where most ideas are selected out. 

![[fig/2015-2018.png]]
```latex
\bigskip
\begin{exhibit}{Pilot Study: Predictions based on Idea Submissions}[21][1][r]
\medskip
\centerline{\colorbox{white}{\framebox{\includegraphics[width=0.9 \linewidth]{fig/2015-2018.pdf}}}}
\captionof{figure}{Predictions based on Idea Submissions}
\captionsetup{font={footnotesize,it}}
\vspace{-0.3cm}
\captionof*{figure}{Source: Author.}
\end{exhibit}
```

Exhibit [r#exhibit:Pilot-Study:-Predictions-based-on-Idea-Submissions] shows the numeric outcome of the pilot study very well, and exhibit [r#exhibit:Pilot-Study:-Stepwise-Predictions-of-Team-Success] illustrates the findings graphically: While the accuracy of the prediction of where an idea would end up increases as the teams move through the program---seen by the light blue circle getting smaller as the targeting gets more precise (exhibit [r#exhibit:Pilot-Study:-Stepwise-Predictions-of-Team-Success] a), at the same time, the uncertainty, visualized by the radius of the white circle, increases because less and less ideas are available to train the model. 
\bigskip

![[fig/pilot_outcome_stepwise.png]]
```latex
\begin{exhibit}{Pilot Study: Stepwise Predictions of Team Success}[21][1][r]
\medskip
\centerline{\colorbox{white}{\framebox{\includegraphics[width=0.9 \linewidth]{fig/pilot_outcome_stepwise.pdf}}}}
\captionof{figure}{Stepwise Predictions of Team Success}
\captionsetup{font={footnotesize,it}}
\vspace{-0.3cm}
\captionof*{figure}{Source: Author.}
\end{exhibit}
```

When using an alternative approach of predicting the advancement of an idea not based on its initial submission, but in addition in comparison to the stage that it survived (exhibit [r#exhibit:Pilot-Study:-Stepwise-Predictions-of-Team-Success] b), the utilized machine learning approach becomes much more balanced in terms of accuracy, and the influence of uncertainty strongly decreases.

These findings of the pilot study, together with further discussions with the program management of SAP's intrapreneurship program, have prompted for a change of the research question: As the program evolves, much less emphasis is placed on the ideas themselves and much more on the selection of the right experts. This is in line with the findings of the pilot study which confirmed the utility of machine learning procedures for the identification of promising candidates from a corpus of text, but also showed the limitations of basing that analysis only on initial idea submissions.


