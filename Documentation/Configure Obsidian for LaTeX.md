# Configure Obsidian for LaTeX

## Install Obisidan

Download and install Obsidian from [here](https://obsidian.md)

## Turn On Community Plugins

Go to Settings, and turn on community plugins.


## Install Citations Plugin

Go to Settings, Community Plugins, Browse, search for and install Citations Plugin.

Configure it as shown here (set the path to where ever you actually put the Bibliography file):

![latex_win_obsidian.png](Attachments/latex_win_obsidian.png)


![latex_win_obsidian_2.png](Attachments/latex_win_obsidian_2.png)


This is the template that I use for new citations notes:

```
{{authorString}}
year: {{year}}
---
[See in BibDesk](x-bdsk://{{citekey}})

#source

## Notes and Quotes
```

Note that the BibDesk link only really works under MacOS; this allows you to jump, from a given citation note, directly to the BibDesk entry in your bibliography.


## Configure Hotkeys
Open the Hotkeys configuration for Obsidian, filter for `citations` and set the hotkeys as marked below:

![](Attachments/latex_win_obsidian_3.png)


With that, you can

1. Use `Ctrl+Shift+I` to insert a citation
2. Use `Ctrl+Shift+O` to insert a reference note



