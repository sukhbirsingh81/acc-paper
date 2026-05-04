% vim: set ft=tex :

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{fsdthesis}[2022/04/08 FSD Thesis Template]

\LoadClass[
  fontsize=11pt,
  a4paper,
  twoside,
  parskip=true,
  tocdepth=3,
  toc=listof,
  bibliography=totoc,
  captions=signature,
  open=right,
  chapterentrydots=on,
  listof=flat,
]{scrbook}

\RequirePackage{ifthen}
\RequirePackage{scrdate}

\RequirePackage[english,ngerman]{babel}

\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage{helvet}
\RequirePackage[headsepline,footsepline]{scrlayer-scrpage}
\RequirePackage{enumitem}
\RequirePackage{lastpage}
\RequirePackage[font=footnotesize,justification=centering]{caption}
\RequirePackage{placeins}
\RequirePackage[hypcap=true]{subcaption}
\RequirePackage{booktabs}
\RequirePackage[acronym,nomain,nonumberlist,section,style=long,nopostdot]{glossaries}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{mathtools}
\RequirePackage{bm}
\RequirePackage{siunitx}
\RequirePackage{tabu}
\RequirePackage[
  tickmarkheight=0.5ex,
]{todonotes}
\RequirePackage[autostyle=true]{csquotes}

\RequirePackage[
  backend=biber,
  bibencoding=utf8,
  style=ieee,
  maxnames=4,
  dashed=false,
]{biblatex}
\addbibresource{References.bib}

\RequirePackage{graphicx}
\graphicspath{{graphics}}

\RequirePackage{tikz}
\RequirePackage{tikzpagenodes}
\usetikzlibrary{calc}

\RequirePackage{varwidth}

\RequirePackage[
  inner=25mm,
  outer=25mm,
  top=30mm,
  headheight=12mm,
  headsep=5mm,
  bottom=35mm,
  footskip=22mm,
  marginparsep=2mm,
  marginparwidth=22mm,
]{geometry}
\setlength{\footheight}{12mm}

\RequirePackage{algorithm}
\RequirePackage{algorithmicx}
\RequirePackage{algpseudocode}

\RequirePackage{listings}

\RequirePackage[figure,table,algorithm,lstlisting]{totalcount}

\RequirePackage[
  unicode=true,
  hidelinks,
  breaklinks=true,
  bookmarksopen,
  pdfdisplaydoctitle,
  pdfpagemode=UseOutlines,
  colorlinks=false,
]{hyperref}
\RequirePackage[nameinlink,capitalise,english,ngerman]{cleveref}
\RequirePackage{scrhack}

%------------------------------------------------------------------------------
% Class options
%
% Options are not passed via \documentclass[options]{class}; instead, we use a
% separate macro \fsdthesisSetup{options}.
%
% Rationale:
%   LaTeX passes all global document class options to all loaded packages.
%   Since every package has its own interpretation of the keys and various
%   different parsers are implemented, it is basically impossible to use this
%   mechanism without breaking something.

% Based on https://tex.stackexchange.com/a/309487
\RequirePackage{xkeyval}
\newif\iffsdthesis@setup
\newcommand*{\fsdthesis@defineOption}[2]{%
  \expandafter\newif\csname iffsdthesis@options@#1@specified\endcsname
  \expandafter\gdef\csname fsdthesis@options@#1@default\endcsname{#2}
  \expandafter\gdef\csname fsdthesis@options@#1@value\endcsname{#2}
  \define@key{fsdthesis}{#1}{%
    \expandafter\gdef\csname fsdthesis@options@#1@value\endcsname{##1}
    \global\expandafter\csname fsdthesis@options@#1@specifiedtrue\endcsname
    \global\fsdthesis@setuptrue
  }
}
\fsdthesis@defineOption{language}{en}
\fsdthesis@defineOption{type}{}
\fsdthesis@defineOption{title}{UNSPECIFIED TITLE}
\fsdthesis@defineOption{subtitle}{UNSPECIFIED SUBTITLE / TRANSLATED TITLE}
\fsdthesis@defineOption{authorLabelForm}{d}
\fsdthesis@defineOption{author}{UNSPECIFIED AUTHOR}
\fsdthesis@defineOption{authorID}{00000000}
\fsdthesis@defineOption{examinersLabelForm}{m}
\fsdthesis@defineOption{examiners}{Prof. Dr.-Ing. Florian Holzapfel}
\fsdthesis@defineOption{supervisorsLabelForm}{D}
\fsdthesis@defineOption{supervisors}{UNSPECIFIED SUPERVISORS}
\fsdthesis@defineOption{date}{\ISOToday}
\fsdthesis@defineOption{place}{Garching}
\fsdthesis@defineOption{university}{Technical University of Munich}
\fsdthesis@defineOption{universityLogoTitle}{graphics/Logo-TUM-color.pdf}
\fsdthesis@defineOption{universityLogoHeader}{graphics/Logo-TUM-black.pdf}
\fsdthesis@defineOption{institute}{Institute of Flight System Dynamics}
\fsdthesis@defineOption{instituteLogoTitle}{graphics/Logo-FSD-color.pdf}
\fsdthesis@defineOption{instituteLogoHeader}{graphics/Logo-FSD-black.pdf}
\fsdthesis@defineOption{partner}{}
\fsdthesis@defineOption{partnerLogoTitle}{}
\fsdthesis@defineOption{partnerLogoHeader}{}
\fsdthesis@defineOption{anonymize}{}
\newcommand{\fsdthesisSetup}[1]{\setkeys{fsdthesis}{#1}}

%------------------------------------------------------------------------------
% Localization / multi-lingual template

\newcommand*{\fsdthesis@labels@abstractTitle@en}{Abstract}
\newcommand*{\fsdthesis@labels@abstractTitle@de}{Kurzfassung}

\newcommand*{\fsdthesis@localizeLabels@en}{%
  \ClassInfo{fsdthesis}{Initializing English labels}
  \global\newcommand*{\fsdthesis@language@babel}{english}
  % university and institute labels
  \global\newcommand*{\fsdthesis@labels@university}{Technical University of Munich}
  \global\newcommand*{\fsdthesis@labels@institute}{Institute of Flight System Dynamics}
  \global\newcommand*{\fsdthesis@labels@partner}{}
  % thesis type labels
  \global\newcommand*{\fsdthesis@labels@type@MSc}{Master's Thesis}
  \global\newcommand*{\fsdthesis@labels@type@BSc}{Bachelor's Thesis}
  \global\newcommand*{\fsdthesis@labels@type@semester}{Semester Thesis}
  \global\newcommand*{\fsdthesis@labels@type@IDP}{Interdisciplinary Project}
  % author ID labels
  \global\newcommand*{\fsdthesis@labels@authorID}{Matriculation Number}
  % author labels
  \global\newcommand*{\fsdthesis@labels@author@f}{Author}
  \global\newcommand*{\fsdthesis@labels@author@m}{Author}
  \global\newcommand*{\fsdthesis@labels@author@d}{Author}
  % examiner labels
  \global\newcommand*{\fsdthesis@labels@examiners@f}{Examiner}
  \global\newcommand*{\fsdthesis@labels@examiners@m}{Examiner}
  \global\newcommand*{\fsdthesis@labels@examiners@d}{Examiner}
  \global\newcommand*{\fsdthesis@labels@examiners@F}{Examiners}
  \global\newcommand*{\fsdthesis@labels@examiners@M}{Examiners}
  \global\newcommand*{\fsdthesis@labels@examiners@D}{Examiners}
  % supervisor labels
  \global\newcommand*{\fsdthesis@labels@supervisors@f}{Supervisor}
  \global\newcommand*{\fsdthesis@labels@supervisors@m}{Supervisor}
  \global\newcommand*{\fsdthesis@labels@supervisors@d}{Supervisor}
  \global\newcommand*{\fsdthesis@labels@supervisors@F}{Supervisors}
  \global\newcommand*{\fsdthesis@labels@supervisors@M}{Supervisors}
  \global\newcommand*{\fsdthesis@labels@supervisors@D}{Supervisors}
  % document structure
  \global\newcommand*{\fsdthesis@labels@abstractTitle}{\fsdthesis@labels@abstractTitle@en}
  \global\newcommand*{\fsdthesis@labels@contentsTitle}{Table of Contents}
  \global\newcommand*{\fsdthesis@labels@listOfFiguresTitle}{List of Figures}
  \global\newcommand*{\fsdthesis@labels@listOfTablesTitle}{List of Tables}
  \global\newcommand*{\fsdthesis@labels@listOfAlgorithmsTitle}{List of Algorithms}
  \global\newcommand*{\fsdthesis@labels@listOfListingsTitle}{List of Listings}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@title}{Table of Acronyms}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@acronym}{Acronym}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@description}{Description}
  \global\newcommand*{\fsdthesis@labels@listOfSymbolsTitle}{Table of Symbols}
  \global\newcommand*{\fsdthesis@labels@statutoryDeclarationTitle}{Statutory Declaration}
  \global\newcommand*{\fsdthesis@labels@referencesTitle}{References}
  \global\newcommand*{\fsdthesis@labels@acknowledgementsTitle}{Acknowledgements}
  \global\newcommand*{\fsdthesis@labels@table}{Table}
  \global\newcommand*{\fsdthesis@labels@figure}{Figure}
  \global\newcommand*{\fsdthesis@labels@listing}{Listing}
  \global\newcommand*{\fsdthesis@labels@listing@cref}{listing}
  \global\newcommand*{\fsdthesis@labels@listing@cref@plural}{listings}
  \global\newcommand*{\fsdthesis@labels@listing@Cref}{Listing}
  \global\newcommand*{\fsdthesis@labels@listing@Cref@plural}{Listings}
  % Statutory declaration
  \global\newcommand{\makeStatutoryDeclaration}{
    \noindent
    \fsdthesis@labels@statutoryDeclarationTitle{}
    \markboth{\fsdthesis@labels@statutoryDeclarationTitle}%
      {\fsdthesis@labels@statutoryDeclarationTitle}

    \vspace{5mm}

    I, \fsdthesis@author, declare on oath towards the \fsdthesis@institute{} of
    \fsdthesis@university{}, that I have prepared the present \fsdthesis@type{}
    independently and with the aid of nothing but the resources listed in the
    bibliography.

    This thesis has neither as-is nor similarly been submitted to any other
    university.

    \vspace{5mm}

    \fsdthesis@place, \fsdthesis@date{}

    \vspace{15mm}
    \noindent\fsdthesis@author{}
  }
  %
  \ClassInfo{fsdthesis}{English labels initialized}
}

\newcommand*{\fsdthesis@localizeLabels@de}{%
  \global\newcommand*{\fsdthesis@language@babel}{ngerman}
  \ClassInfo{fsdthesis}{Initializing German labels}
  % university and institute labels
  \global\newcommand*{\fsdthesis@labels@university}{Technische Universität München}
  \global\newcommand*{\fsdthesis@labels@institute}{Lehrstuhl für Flugsystemdynamik}
  \global\newcommand*{\fsdthesis@labels@partner}{}
  % thesis type labels
  \global\newcommand*{\fsdthesis@labels@type@MSc}{Masterarbeit}
  \global\newcommand*{\fsdthesis@labels@type@BSc}{Bachelorarbeit}
  \global\newcommand*{\fsdthesis@labels@type@semester}{Semesterarbeit}
  \global\newcommand*{\fsdthesis@labels@type@IDP}{Interdisziplinäres Projekt}
  % author ID labels
  \global\newcommand*{\fsdthesis@labels@authorID}{Matrikelnummer}
  % author labels
  \global\newcommand*{\fsdthesis@labels@author@f}{Autorin}
  \global\newcommand*{\fsdthesis@labels@author@m}{Autor}
  \global\newcommand*{\fsdthesis@labels@author@d}{Autor*in}
  % examiner labels
  \global\newcommand*{\fsdthesis@labels@examiners@f}{Prüferin}
  \global\newcommand*{\fsdthesis@labels@examiners@m}{Prüfer}
  \global\newcommand*{\fsdthesis@labels@examiners@d}{Prüfer*in}
  \global\newcommand*{\fsdthesis@labels@examiners@F}{Prüferinnen}
  \global\newcommand*{\fsdthesis@labels@examiners@M}{Prüfer}
  \global\newcommand*{\fsdthesis@labels@examiners@D}{Prüfer*innen}
  % supervisor labels
  \global\newcommand*{\fsdthesis@labels@supervisors@f}{Betreuerin}
  \global\newcommand*{\fsdthesis@labels@supervisors@m}{Betreuer}
  \global\newcommand*{\fsdthesis@labels@supervisors@d}{Betreuer*in}
  \global\newcommand*{\fsdthesis@labels@supervisors@F}{Betreuerinnen}
  \global\newcommand*{\fsdthesis@labels@supervisors@M}{Betreuer}
  \global\newcommand*{\fsdthesis@labels@supervisors@D}{Betreuer*innen}
  % document structure
  \global\newcommand*{\fsdthesis@labels@abstractTitle}{\fsdthesis@labels@abstractTitle@de}
  \global\newcommand*{\fsdthesis@labels@contentsTitle}{Inhaltsverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfFiguresTitle}{Abbildungsverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfTablesTitle}{Tabellenverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfAlgorithmsTitle}{Algorithmenverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfListingsTitle}{Quelltextverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@title}{Abkürzungsverzeichnis}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@acronym}{Abkürzung}
  \global\newcommand*{\fsdthesis@labels@listOfAcronyms@description}{Beschreibung}
  \global\newcommand*{\fsdthesis@labels@listOfSymbolsTitle}{Symbolverzeichnis}
  \global\newcommand*{\fsdthesis@labels@statutoryDeclarationTitle}{Eidesstattliche Erklärung}
  \global\newcommand*{\fsdthesis@labels@referencesTitle}{Literaturverzeichnis}
  \global\newcommand*{\fsdthesis@labels@acknowledgementsTitle}{Danksagung}
  \global\newcommand*{\fsdthesis@labels@table}{Tabelle}
  \global\newcommand*{\fsdthesis@labels@figure}{Abbildung}
  \global\newcommand*{\fsdthesis@labels@listing}{Quelltext}
  \global\newcommand*{\fsdthesis@labels@listing@cref}{Quelltext}
  \global\newcommand*{\fsdthesis@labels@listing@cref@plural}{Quelltexte}
  \global\newcommand*{\fsdthesis@labels@listing@Cref}{Quelltext}
  \global\newcommand*{\fsdthesis@labels@listing@Cref@plural}{Quelltexte}
  % Statutory declaration
  \global\newcommand{\makeStatutoryDeclaration}{
    \noindent
    \fsdthesis@labels@statutoryDeclarationTitle{}
    \markboth{\fsdthesis@labels@statutoryDeclarationTitle}%
      {\fsdthesis@labels@statutoryDeclarationTitle}

    \vspace{5mm}

    Hiermit erkläre ich, \fsdthesis@author, gegenüber dem
    \fsdthesis@institute{} der \fsdthesis@university, dass ich die
    vorliegende \fsdthesis@type{} selbstständig und ausschließlich
    unter Zuhilfenahme der im Literaturverzeichnis genannten Quellen
    angefertigt habe.

    Die Arbeit wurde in gleicher oder ähnlicher Form an keiner anderen
    Hochschule oder Universität vorgelegt.

    \vspace{5mm}

    \fsdthesis@place, \fsdthesis@date{}

    \vspace{15mm}
    \noindent\fsdthesis@author{}
  }

  \ClassInfo{fsdthesis}{German labels initialized}
}

\newcommand*{\fsdthesis@translate}[1]{\expandafter\csname #1@\fsdthesis@language\endcsname}

\newcommand*{\fsdthesis@warnIfOptionNotSpecified}[1]{%
  \expandafter\csname iffsdthesis@options@#1@specified\endcsname
  \else
    \ClassWarningNoLine{fsdthesis}{Option {#1} not specified}
  \fi
}

\AtBeginDocument{
  \iffsdthesis@setup
  \else
    \ClassError{fsdthesis}{%
      \protect\fsdthesisSetup{} must be called before \protect\begin{document}%
    }{}
  \fi

  \fsdthesis@warnIfOptionNotSpecified{language}
  \newcommand*{\fsdthesis@language}{\fsdthesis@options@language@value}
  \ClassInfo{fsdthesis}{Setting up labels for language=\fsdthesis@language}
  \expandafter\fsdthesis@translate{fsdthesis@localizeLabels}
  \expandafter\selectlanguage\expanded{{\fsdthesis@language@babel}}
  \hypersetup{pdflang=\fsdthesis@language}
  %\expandafter\renewcommand\csname\fsdthesis@language@babel tablename\endcsname{\fsdthesis@labels@table}
  %\expandafter\renewcommand\csname\fsdthesis@language@babel figurename\endcsname{\fsdthesis@labels@figure}
  \renewcommand*{\lstlistingname}{\fsdthesis@labels@listing}
  \renewcommand*{\cref@listing@name}{\fsdthesis@labels@listing@cref}
  \renewcommand*{\cref@listing@name@plural}{\fsdthesis@labels@listing@cref@plural}
  \renewcommand*{\Cref@listing@name}{\fsdthesis@labels@listing@Cref}
  \renewcommand*{\Cref@listing@name@plural}{\fsdthesis@labels@listing@Cref@plural}

  \ClassInfo{fsdthesis}{Setting up university info}
  \iffsdthesis@options@university@specified
    \newcommand*{\fsdthesis@university}{\fsdthesis@options@university@value}
    \newcommand*{\fsdthesis@universityLogoTitle}{\fsdthesis@options@universityLogoTitle@value}
    \newcommand*{\fsdthesis@universityLogoHeader}{\fsdthesis@options@universityLogoHeader@value}
  \else
    \newcommand*{\fsdthesis@university}{\fsdthesis@labels@university}
    \newcommand*{\fsdthesis@universityLogoTitle}{\fsdthesis@options@universityLogoTitle@default}
    \newcommand*{\fsdthesis@universityLogoHeader}{\fsdthesis@options@universityLogoHeader@default}
  \fi
  \ClassInfo{fsdthesis}{university={\fsdthesis@university}}
  \ClassInfo{fsdthesis}{universityLogoTitle={\fsdthesis@universityLogoTitle}}
  \ClassInfo{fsdthesis}{universityLogoHeader={\fsdthesis@universityLogoHeader}}

  \ClassInfo{fsdthesis}{Setting up institute info}
  \iffsdthesis@options@institute@specified
    \newcommand*{\fsdthesis@institute}{\fsdthesis@options@institute@value}
    \newcommand*{\fsdthesis@instituteLogoTitle}{\fsdthesis@options@instituteLogoTitle@value}
    \newcommand*{\fsdthesis@instituteLogoHeader}{\fsdthesis@options@instituteLogoHeader@value}
  \else
    \newcommand*{\fsdthesis@institute}{\fsdthesis@labels@institute}
    \newcommand*{\fsdthesis@instituteLogoTitle}{\fsdthesis@options@instituteLogoTitle@default}
    \newcommand*{\fsdthesis@instituteLogoHeader}{\fsdthesis@options@instituteLogoHeader@default}
  \fi
  \ClassInfo{fsdthesis}{institute={\fsdthesis@institute}}
  \ClassInfo{fsdthesis}{instituteLogoHeader={\fsdthesis@instituteLogoTitle}}
  \ClassInfo{fsdthesis}{instituteLogoHeader={\fsdthesis@instituteLogoHeader}}

  \ClassInfo{fsdthesis}{Setting up partner info}
  \iffsdthesis@options@partner@specified
    \newcommand*{\fsdthesis@partner}{\fsdthesis@options@partner@value}
    \newcommand*{\fsdthesis@partnerLogoTitle}{\fsdthesis@options@partnerLogoTitle@value}
    \newcommand*{\fsdthesis@partnerLogoHeader}{\fsdthesis@options@partnerLogoHeader@value}
  \else
    \newcommand*{\fsdthesis@partner}{\fsdthesis@labels@partner}
    \newcommand*{\fsdthesis@partnerLogoTitle}{\fsdthesis@options@partnerLogoTitle@default}
    \newcommand*{\fsdthesis@partnerLogoHeader}{\fsdthesis@options@partnerLogoHeader@default}
  \fi
  \ClassInfo{fsdthesis}{partner={\fsdthesis@partner}}
  \ClassInfo{fsdthesis}{partnerLogoTitle={\fsdthesis@partnerLogoTitle}}
  \ClassInfo{fsdthesis}{partnerLogoHeader={\fsdthesis@partnerLogoHeader}}

  \ClassInfo{fsdthesis}{Setting up thesis info}
  \fsdthesis@warnIfOptionNotSpecified{type}
  \newcommand*{\fsdthesis@type}{%
    \expandafter\csname%
      fsdthesis@labels@type@\fsdthesis@options@type@value\endcsname}
  \ClassInfo{fsdthesis}{type={\fsdthesis@type}}

  \fsdthesis@warnIfOptionNotSpecified{title}
  \fsdthesis@warnIfOptionNotSpecified{subtitle}
  \newcommand*{\fsdthesis@title}{\fsdthesis@options@title@value}
  \newcommand*{\fsdthesis@subtitle}{\fsdthesis@options@subtitle@value}
  \ClassInfo{fsdthesis}{title={\fsdthesis@title}}
  \ClassInfo{fsdthesis}{subtitle={\fsdthesis@subtitle}}

  \newif\iffsdthesisAnonymize

  \ifthenelse{\equal{\fsdthesis@options@anonymize@value}{true}}{%
    \fsdthesisAnonymizetrue}{}

  \iffsdthesisAnonymize
    \ClassWarningNoLine{fsdthesis}{%
      Erasing personal information ({anonymize=true})}
    \renewcommand*{\fsdthesis@options@authorLabelForm@value}{d}
    \renewcommand*{\fsdthesis@options@author@value}{(AUTHOR)}  % TODO phantom?
    \renewcommand*{\fsdthesis@options@authorID@value}{00000000}  % TODO phantom?
    \renewcommand*{\fsdthesis@options@examinersLabelForm@value}{D}
    \renewcommand*{\fsdthesis@options@examiners@value}{(EXAMINERS)}
    \renewcommand*{\fsdthesis@options@supervisorsLabelForm@value}{D}
    \renewcommand*{\fsdthesis@options@supervisors@value}{(SUPERVISORS)}
  \fi

  \newcommand*{\fsdthesis@authorLabel}{%
    \expandafter\csname%
      fsdthesis@labels@author@\fsdthesis@options@authorLabelForm@value%
      \endcsname}
  \newcommand*{\fsdthesis@author}{%
    \fsdthesis@options@author@value}
  \newcommand*{\fsdthesis@authorID}{%
    \fsdthesis@options@authorID@value}
  \ClassInfo{fsdthesis}{%
    authorLabel={\fsdthesis@authorLabel}, author={\fsdthesis@author}}

  \newcommand*{\fsdthesis@examinersLabel}{%
    \expandafter\csname%
      fsdthesis@labels@examiners@\fsdthesis@options@examinersLabelForm@value%
      \endcsname}
  \newcommand*{\fsdthesis@examiners}{\fsdthesis@options@examiners@value}
  \ClassInfo{fsdthesis}{%
    examinersLabel={\fsdthesis@examinersLabel},
    examiners={\fsdthesis@examiners}}

  \newcommand*{\fsdthesis@supervisorsLabel}{%
    \expandafter\csname%
      fsdthesis@labels@supervisors@\fsdthesis@options@supervisorsLabelForm@value%
      \endcsname}
  \newcommand*{\fsdthesis@supervisors}{\fsdthesis@options@supervisors@value}
  \ClassInfo{fsdthesis}{%
    supervisorsLabel={\fsdthesis@supervisorsLabel},
    supervisors={\fsdthesis@supervisors}}

  \newcommand*{\fsdthesis@date}{\fsdthesis@options@date@value}
  \newcommand*{\fsdthesis@place}{\fsdthesis@options@place@value}
  \ClassInfo{fsdthesis}{date={\fsdthesis@date}, place={\fsdthesis@place}}

  \hypersetup{
    pdftitle={\fsdthesis@title},
    pdfauthor={\fsdthesis@author},
  }

  \newcommand*{\fsdthesis@numberWithinChapter}[1]{\thechapter--\arabic{#1}}
  \renewcommand*{\thetable}{\fsdthesis@numberWithinChapter{table}}
  \renewcommand*{\thefigure}{\fsdthesis@numberWithinChapter{figure}}
  \renewcommand*{\thealgorithm}{\fsdthesis@numberWithinChapter{algorithm}}
  \renewcommand*{\thelstlisting}{\fsdthesis@numberWithinChapter{lstlisting}}

}

\makeglossaries

%------------------------------------------------------------------------------

\renewcommand{\maketitle}{%
  \begin{titlepage}
    \begin{tikzpicture}[remember picture, overlay]

      \node [anchor=north west,align=center]
        at (current page text area.north west)
        {\fsdthesis@university\\[1ex]
          \includegraphics[height=20mm]{\fsdthesis@universityLogoTitle}};
      \node [anchor=north east,align=center]
        at (current page text area.north east)
        {\fsdthesis@institute\\[1ex]
          \includegraphics[height=20mm]{\fsdthesis@instituteLogoTitle}};
      \ifthenelse{\equal{\fsdthesis@partner}{}}{}{%
        \node [anchor=north,align=center]
          at (current page text area.north)
          {\fsdthesis@partner\\[1ex]
            \iffsdthesis@options@partnerLogoTitle@specified
              \includegraphics[height=20mm]{\fsdthesis@partnerLogoTitle}
            \else
            \fi};
      }

      \node [anchor=north,align=flush center,text width=\textwidth] (title)
        at ($(current page text area.north) + (0, -60mm)$)
        {%
          {\Huge\fsdthesis@title}\\[1em]%
          {\Huge--}\\[1em]%
          {\Large\fsdthesis@subtitle}\\[2em]%
          \fsdthesis@type{}%
        };

      \node [anchor=south,align=center] (date)
        at ($(current page text area.south)$) {\fsdthesis@date};

      \path (title.south) -- (date.north) node [pos=0.5,align=flush center] {%
        \fsdthesis@authorLabel: \fsdthesis@author\\[1em]
        \fsdthesis@labels@authorID: \fsdthesis@authorID\\[1em]
        \fsdthesis@supervisorsLabel:
          \begin{varwidth}[t]{0.5\textwidth}
            \fsdthesis@supervisors
          \end{varwidth}\\[1em]
        \fsdthesis@examinersLabel:
          \begin{varwidth}[t]{0.5\textwidth}
            \fsdthesis@examiners
          \end{varwidth}
      };

    \end{tikzpicture}
  \end{titlepage}
}

%------------------------------------------------------------------------------

\newenvironment{frontMatter}{%
  \cleardoubleemptypage\pagenumbering{roman}%
}{}

\newenvironment{mainContent}{%
  \cleardoubleemptypage\pagenumbering{arabic}%
}{}

\newenvironment{backMatter}{%
  \cleardoubleemptypage\pagenumbering{Roman}%
}{}

\newenvironment{abstract}[1]{%
  \ifthenelse{\equal{#1}{en}}{%
    \begin{otherlanguage}{english}
    \noindent\expandafter\fsdthesis@labels@abstractTitle@en\par
  }{%
    \ifthenelse{\equal{#1}{de}}{%
      \begin{otherlanguage}{german}%
      \noindent\expandafter\fsdthesis@labels@abstractTitle@de\par
    }{%
      \ClassError{fsdthesis}{Unsupported language: #1}{}%
    }%
  }
  \markboth{\fsdthesis@labels@abstractTitle}{\fsdthesis@labels@abstractTitle}
  \itshape
}{%
  \end{otherlanguage}\par%
}

\newcommand{\makeTableOfContents}{%
  \cleardoubleemptypage%
  \renewcommand*{\contentsname}{\fsdthesis@labels@contentsTitle}%
  \currentpdfbookmark{\contentsname}{TableOfContents}%
  \tableofcontents%
}

\newcommand{\makeListOfFigures}{%
  \iftotalfigures%
    \cleardoubleemptypage%
    \renewcommand*{\listfigurename}{\fsdthesis@labels@listOfFiguresTitle}%
    \listoffigures%
  \fi%
}

\newcommand{\makeListOfTables}{%
  \iftotaltables%
    \cleardoubleemptypage%
    \renewcommand*{\listtablename}{\fsdthesis@labels@listOfTablesTitle}%
    \listoftables%
  \fi%
}

\newcommand{\makeListOfAlgorithms}{%
  \iftotalalgorithms%
    \cleardoubleemptypage%
    \renewcommand*{\listalgorithmname}{\fsdthesis@labels@listOfAlgorithmsTitle}%
    \phantomsection%
    \addcontentsline{toc}{chapter}{\listalgorithmname}%
    \listofalgorithms%
  \fi
}

\newcommand{\makeListOfListings}{%
  \iftotallstlistings%
    \cleardoubleemptypage%
    \renewcommand*{\lstlistlistingname}{\fsdthesis@labels@listOfListingsTitle}%
    \lstlistoflistings%
  \fi%
}

\newcommand{\makeListOfAcronyms}{%
  \cleardoubleemptypage%
  \renewcommand*{\acronymname}{\fsdthesis@labels@listOfAcronyms@title}%
  \setglossarysection{chapter}%
  \printglossary[type=\acronymtype,style=TableOfAcronyms]%
}

\newcommand{\makeBibliography}{%
  \cleardoubleemptypage%
  \markboth{\fsdthesis@labels@referencesTitle}{\fsdthesis@labels@referencesTitle}%
  \sloppy%
  \printbibliography[%
    title={\fsdthesis@labels@referencesTitle\label{s_references}}%
  ]%
  \fussy%
}

%------------------------------------------------------------------------------
% Style

\renewcommand*{\familydefault}{\sfdefault}
%\setmainfont{Arial}
%\setsansfont{Arial}
\linespread{1.15}

\setkomafont{chapter}{\fontsize{14pt}{1.15}\textbf} % Heading1
\setkomafont{section}{\fontsize{13pt}{1.15}\textbf} % Heading2
\setkomafont{subsection}{\fontsize{11pt}{1.15}\textbf} % Heading3
\setkomafont{subsubsection}{\itshape\fontsize{11pt}{1.15}\textbf} % Heading4
\setkomafont{paragraph}{\fontsize{11pt}{1.15}\textnormal} % Heading5

\setkomafont{caption}{\fontsize{9pt}{1.15}\bfseries}
\setkomafont{captionlabel}{\fontsize{9pt}{1.15}\bfseries}
\captionsetup[figure]{font={bf,footnotesize},labelfont={bf,footnotesize}}
\captionsetup[subfigure]{font={bf,footnotesize},labelfont={bf,footnotesize}}
\captionsetup[table]{font={bf,footnotesize},labelfont={bf,footnotesize}}

\numberwithin{equation}{chapter}
\numberwithin{table}{chapter}
\numberwithin{figure}{chapter}
\numberwithin{algorithm}{chapter}
%\numberwithin{lstlisting}{chapter}  % option numberbychapter

\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{chapter}
\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{section}
\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{subsection}
\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{subsubsection}
\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{paragraph}
\RedeclareSectionCommand[beforeskip=-1\baselineskip,afterskip=0.01\baselineskip]{subparagraph}
\setlength{\parskip}{1\baselineskip}

% Table of Contents
\setkomafont{chapterentry}{\fontsize{11pt}{1.15}\normalfont}
\DeclareTOCStyleEntry{dottedtocline}{section}
\DeclareTOCStyleEntry{dottedtocline}{subsection}
\DeclareTOCStyleEntry{dottedtocline}{subsubsection}
\DeclareTOCStyleEntry[entryformat:=section,linefill=\hfill]{tocline}{chapter}

% Header/footer

\ohead{\\\fontsize{11pt}{1.15}\normalfont\textbf{\headmark}}
\ihead{\includegraphics[height=8mm]{%
  \fsdthesis@options@instituteLogoHeader@value}~%
  \includegraphics[height=8mm]{\fsdthesis@options@universityLogoHeader@value}~%
  \iffsdthesis@options@partnerLogoHeader@specified%
    \includegraphics[height=8mm]{\fsdthesis@options@partnerLogoHeader@value}%
  \else%
  \fi}

\renewcommand{\chaptermark}[1]{\markboth{\thechapter\hspace{1ex}#1}{\thechapter\hspace{1ex}#1}}
\renewcommand{\sectionmark}[1]{}
\renewcommand{\subsectionmark}[1]{}

\ifoot{\normalfont\fsdthesis@title\\\fsdthesis@author}
%\ofoot{\normalfont\\Page \thepage\,/\,\pageref{LastPage}}

% See https://tex.stackexchange.com/questions/122177/changing-the-formatting-of-equation-numbers
\renewcommand{\theequation}{\thechapter--\arabic{equation}}
% numbers right-aligned at text boundary
\def\tagform@#1{\maketag@@@{\fontsize{9pt}{1.15}\normalfont\textbf{(\ignorespaces#1)}\unskip\@@italiccorr}}

\urlstyle{sf}

\let\stdchapter\chapter
\renewcommand{\chapter}{\FloatBarrier\stdchapter}
\let\stdsection\section
\renewcommand{\section}{\FloatBarrier\stdsection}
\let\stdsubsection\subsection
\renewcommand{\subsection}{\FloatBarrier\stdsubsection}
\let\stdsubsubsection\subsubsection
\renewcommand{\subsubsection}{\FloatBarrier\stdsubsubsection}

\pagestyle{scrheadings}
\renewcommand*{\chapterpagestyle}{scrheadings}

\ofoot{\normalfont\\Page \thepage}

\captionsetup{subrefformat=parens}

\AtBeginEnvironment{quote}{\slshape}

\lstset{ %
  basicstyle=\ttfamily,
  commentstyle=\slshape,
  keywordstyle=\bfseries,
  captionpos=t,
  keepspaces=t,
  showstringspaces=false,
  numbers=left,
  numberstyle=\tiny,
  numbersep=5pt,
  frame=l,
  numberbychapter=true,
  captionpos=t,
  breaklines=true,
  postbreak=\mbox{\textcolor{gray}{$\quad\hookrightarrow\;$}},
}
\newcommand\InlineCode[1]{\lstinline[basicstyle=\normalsize\ttfamily]{#1}}

\setlist{nosep} % \setlist{noitemsep}

% Glossary style adapted from
% https://tex.stackexchange.com/questions/207296/aligning-acronyms-to-the-left-and-long-descriptions
\newglossarystyle{TableOfAcronyms}{%
  \renewenvironment{theglossary}%
    {%
      \addcontentsline{toc}{chapter}{\acronymname}%
      \markboth{\acronymname}{\acronymname}%
      \begin{longtable}[l]{@{}ll}%
    }%
    {\end{longtable}}%
  \renewcommand*{\glossaryheader}{%
    \textbf{\fsdthesis@labels@listOfAcronyms@acronym} &
    \textbf{\fsdthesis@labels@listOfAcronyms@description} \endhead
  }%
  \renewcommand*{\glsgroupheading}[1]{}%
  \renewcommand*{\glsgroupskip}{ & \\}%
  \renewcommand*{\glossentry}[2]{%
    \glsentryitem{##1}\glstarget{##1}{\glossentryname{##1}}
      & \glsentrydesc{##1}
      \\
  }
}

%------------------------------------------------------------------------------
\DeclareMathOperator{\arcsinh}{arcsinh}
\DeclareMathOperator{\arccosh}{arccosh}
\DeclareMathOperator{\arctanh}{arctanh}
\DeclareMathOperator{\arctantwo}{arctan2}
\newcommand{\T}{\mathsf{T}}
\newcommand{\HT}{\mathsf{H}}
\newcommand{\iu}{\mathrm{i}}
