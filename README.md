<img src="logo/MAML_icon.png" width="75" align="left">
# <br /> &nbsp; MAML &ndash; <br /> &nbsp; Münster App Modeling Language
<br />
MAML is a framework for cross-platform development of native business apps using a graphical modeling language.

## Repository content
This repository contains the latest source code, which may be unstable.
MAML resides in the namespace de.wwu.maml and has the following structure:

* ~.grammar: MAML Ecore model //TODO merge
* ~.editor: MAML editor based on the [Eclipse Sirius](https://eclipse.org/sirius/) project //TODO merge
  * ~.design: The editor and its services
  * ~.diagram: Custom diagram elements for the editor
  * ~.dialog: Custom dialogs for the editor
* ~.inference: Data model inference from graphical MAML artifacts // TODO make a separate component
* ~.md2converter: [QVTo](https://projects.eclipse.org/projects/modeling.mmt.qvt-oml) model-to-model transformation to the textual MD² DSL from which platform code can be generated according to the [MD² website](http://wwu-pi.github.io/md2-web/)
