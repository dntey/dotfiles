;;; kanagawa-dark-theme.el --- inspired by morhetz's Gruvbox -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Added: May 1, 2019 (#277)
;; Author: JongW <https://github.com/JongW>
;; Maintainer:
;; Source: https://github.com/morhetz/gruvbox
;;
;;; Commentary:
;;; Code:

(require 'doom-themes)

;; Compiler pacifier
(defvar modeline-bg)


;;
;;; Variables

(defgroup kanagawa-dark-theme nil
  "Options for kanagawa-dark."
  :group 'doom-themes)

(defcustom kanagawa-dark-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'kanagawa-dark-theme
  :type 'boolean)

(defcustom kanagawa-dark-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'kanagawa-dark-theme
  :type '(choice integer boolean))

(defcustom kanagawa-dark-dark-variant nil
  "A choice of \"hard\" or \"soft\" can be used to change the
background contrast. All other values default to \"medium\"."
  :group 'kanagawa-dark-theme
  :type  'string)


;;
;;; Theme definition

(def-doom-theme kanagawa-dark
  "Dark theme with pastel 'retro groove' colors."
  :family 'kanagawa-dark
  :background-mode 'dark

  ;; name        gui       256       16
  ((bg         '("#1f1f28" "#1f1f28" nil  ))
   (bg-alt     '("#2A2A37" "#2A2A37" nil  ))
   (bg-alt2    '("#363646" "#363646" nil  )) ; bg2 (for region, selection etc.)

   (base0      '("#0d0c0c" "black"   "black"      )) ; (self-defined)
   (base1      '("#181820" "#181820" "brightblack")) ; bg0_h
   (base2      '("#1a1a22" "#1a1a22" "brightblack")) ; bg0
   (base3      '("#1F1F28" "#1F1F28" "brightblack")) ; bg1
   (base4      '("#2A2A37" "#2A2A37" "brightblack")) ; bg3
   (base5      '("#363646" "#363646" "brightblack")) ; bg4
   (base6      '("#54546D" "#54546D" "brightblack")) ; gray
   (base7      '("#43436c" "#43436c" "brightblack")) ; fg2
   (base8      '("#dcd7ba" "#dcd7ba" "brightwhite")) ; fg0
   (fg         '("#d5cea3" "#d5cea3" "brightwhite")) ; fg/fg1
   (fg-alt     '("#f2ecbc" "#f2ecbc" "brightwhite")) ; fg2

   (grey       '("#727169" "#8a8a8a" "grey"            )) ;; gruvbox-gray
   (red        '("#E82424" "#870000" "red"             )) ;; gruvbox-bright_red
   (orange     '("#FF9E3B" "#af5f00" "brightred"       )) ;; gruvbox-bright_orange
   (green      '("#98BB6C" "#878700" "green"           )) ;; gruvbox-bright_green
   (dark-green '("#6f894E" "#98971a" "green"))         ; green
   (teal       '("#4E8CA2" "#44b9b1" "brightgreen"     )) ;; gruvbox-
   (yellow     '("#f9d791" "#af8700" "yellow"          )) ;; gruvbox-bright_yellow
   (dark-yellow '("#de9800" "#fabd2f" "yellow"))        ; yellow
   (blue       '("#2D4F67" "#005f87" "brightblue"      )) ;; gruvbox-bright_blue
   (dark-blue  '("#223249" "#000087" "blue"            )) ;; gruvbox-dark_blue
   (magenta    '("#E46876" "#d75f87" "magenta"         )) ;; gruvbox-faded_purple
   (violet     '("#957FB8" "#875f87" "brightmagenta"   )) ;; gruvbox-bright_purple
   (cyan       '("#7FB4CA" "#5f8787" "brightcyan"      )) ;; gruvbox-bright_aqua
   (dark-cyan  '("#7E9CD8" "#005f5f" "cyan"            )) ;; gruvbox-dark_aqua

   (waveBlue1     '("#223249" nil nil ))
   (waveBlue2     '("#2D4F67" nil nil ))
   (winterGreen   '("#2B3328" nil nil ))
   (winterYellow  '("#49443C" nil nil ))
   (winterRed     '("#43242B" nil nil ))
   (winterBlue    '("#252535" nil nil ))
   (autumnGreen   '("#76946A" nil nil ))
   (autumnRed     '("#C34043" nil nil ))
   (autumnYellow  '("#DCA561" nil nil ))

   (lotusInk1     '("#545464" nil nil ))
   (lotusInk2     '("#43436c" nil nil ))
   (lotusGray     '("#dcd7ba" nil nil ))
   (lotusGray2    '("#716e61" nil nil ))
   (lotusGray3    '("#8a8980" nil nil ))

   (lotusWhite0   '("#d5cea3" nil nil ))
   (lotusWhite1   '("#dcd5ac" nil nil ))
   (lotusWhite2   '("#e5ddb0" nil nil ))
   (lotusWhite3   '("#f2ecbc" nil nil ))
   (lotusWhite4   '("#e7dba0" nil nil ))
   (lotusWhite5   '("#e4d794" nil nil ))
   (lotusViolet1  '("#a09cac" nil nil ))
   (lotusViolet2  '("#766b90" nil nil ))
   (lotusViolet3  '("#c9cbd1" nil nil ))
   (lotusViolet4  '("#624c83" nil nil ))
   (lotusBlue1    '("#c7d7e0" nil nil ))
   (lotusBlue2    '("#b5cbd2" nil nil ))
   (lotusBlue3    '("#9fb5c9" nil nil ))
   (lotusBlue4    '("#4d699b" nil nil ))
   (lotusBlue5    '("#5d57a3" nil nil ))
   (lotusGreen    '("#6f894e" nil nil ))
   (lotusGreen2   '("#6e915f" nil nil ))
   (lotusGreen3   '("#b7d0ae" nil nil ))
   (lotusPink     '("#b35b79" nil nil ))
   (lotusOrange   '("#cc6d00" nil nil ))
   (lotusOrange2  '("#e98a00" nil nil ))
   (lotusYellow   '("#77713f" nil nil ))
   (lotusYellow2  '("#836f4a" nil nil ))
   (lotusYellow3  '("#de9800" nil nil ))
   (lotusYellow4  '("#f9d791" nil nil ))
   (lotusRed      '("#c84053" nil nil ))
   (lotusRed2     '("#d7474b" nil nil ))
   (lotusRed3     '("#e82424" nil nil ))
   (lotusRed4     '("#d9a594" nil nil ))
   (lotusAqua     '("#597b75" nil nil ))
   (lotusAqua2    '("#5e857a" nil nil ))
   (lotusTeal1    '("#4e8ca2" nil nil ))
   (lotusTeal2    '("#6693bf" nil nil ))
   (lotusTeal3    '("#5a7785" nil nil ))
   (lotusCyan     '("#d7e3d8" nil nil ))
   (surimiOrange  '("#FFA066" nil nil ))
   (sakuraPink    '("#D27E99" nil nil ))
   (waveAqua2     '("#7AA89F" nil nil ))
   (boatYellow2   '("#C0A36E" nil nil ))
   (carpYellow    '("#E6C384" nil nil ))
   (oniViolet     '("#957Fb8" nil nil ))
   (oniViolet2    '("#b8b4d0" nil nil ))
   (waveRed       '("#E46876" nil nil ))
   (springViolet2 '("#9CABCA" nil nil ))
   (crystalBlue   '("#7E9CD8" nil nil ))


   ;; face categories
   (keywords       oniViolet)
   (functions      crystalBlue)
   (type           waveAqua2)
   (constants      surimiOrange)
   (numbers        sakuraPink)
   (operators      boatYellow2)
   (variables      springViolet2)

   (highlight      yellow)
   (vertical-bar   bg-alt2)
   (selection      waveBlue1)
   (builtin        autumnYellow)
   (comments       (if kanagawa-dark-brighter-comments magenta grey))
   (doc-comments   (if kanagawa-dark-brighter-comments (doom-lighten magenta 0.2) (doom-lighten fg-alt 0.25)))
   (methods        waveRed)
   (strings        green)
   (region         bg-alt2)
   (error          red)
   (warning        lotusRed4)
   (success        green)

   (vc-modified    (doom-darken cyan 0.15))
   (vc-added       (doom-darken green 0.15))
   (vc-deleted     (doom-darken red 0.15))

   ;; custom categories
   (-modeline-pad
    (when kanagawa-dark-padded-modeline
      (if (integerp kanagawa-dark-padded-modeline)
          kanagawa-dark-padded-modeline
        4)))
   (modeline-bg bg-alt2)
   (modeline-fg (doom-lighten fg-alt 0.25))
   (modeline-inactive-bg (doom-darken modeline-bg 0.15))
   (modeline-inactive-fg base6)

   (org-quote `(,(doom-lighten (car bg) 0.05) lotusGray3)))


  ;;;; Base theme face overrides
  ((button :foreground cyan :underline t :weight 'bold)
   (cursor :background yellow)
   (hl-line :background base3)
   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :background base3 :foreground yellow)
   (isearch :foreground base6 :background lotusTeal1)
   (lazy-highlight :background lotusTeal1 :foreground base0 :distant-foreground base0 :bold bold)
   ((link &override) :foreground violet)
   (minibuffer-prompt :foreground cyan)
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background bg :foreground base6
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-inactive-bg)))

   ;;;; company
   (company-preview-common :foreground cyan)
   (company-tooltip-common :foreground cyan)
   (company-tooltip-common-selection :foreground cyan)
   (company-tooltip-annotation :foreground cyan)
   (company-tooltip-annotation-selection :foreground cyan)
   (company-scrollbar-bg :background base3)
   (company-scrollbar-fg :background cyan)
   (company-tooltip-selection :background bg-alt2)
   (company-tooltip-mouse :background bg-alt2 :foreground nil)
   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground keywords)
   ;;;; doom-emacs
   (+workspace-tab-selected-face :background lotusInk2 :foreground lotusGray)
   ;;;; doom-modeline
   (doom-modeline-project-dir :bold t :foreground cyan)
   (doom-modeline-buffer-path :inherit 'bold :foreground green)
   (doom-modeline-buffer-file :inherit 'bold :foreground lotusWhite5)
   (doom-modeline-buffer-modified :inherit 'bold :foreground red)
   (doom-modeline-error :background bg)
   (doom-modeline-buffer-major-mode :foreground violet :bold t)
   (doom-modeline-info :bold t :foreground cyan)
   (doom-modeline-bar :background dark-green)
   (doom-modeline-panel :background dark-green :foreground fg)
   ;;;; doom-themes
   (doom-themes-neotree-file-face :foreground fg)
   (doom-themes-neotree-hidden-file-face :foreground (doom-lighten fg-alt 0.25))
   (doom-themes-neotree-media-file-face :foreground (doom-lighten fg-alt 0.25))
   ;;;; emacs-lisp-mode
   (highlight-quoted-symbol :foreground dark-cyan)
   ;;;; ediff <built-in>
   (ediff-fine-diff-A    :background (doom-blend red bg 0.4) :weight 'bold)
   (ediff-current-diff-A :background (doom-blend red bg 0.2))
   ;;;; evil
   (evil-search-highlight-persist-highlight-face :background yellow)
   (evil-ex-substitute-replacement :foreground cyan :strike-through nil :inherit 'evil-ex-substitute-matches)
   ;;;; evil-snipe
   (evil-snipe-first-match-face :foreground "white" :background yellow)
   (evil-snipe-matches-face     :foreground yellow :bold t :underline t)
   ;;;; flycheck
   (flycheck-error   :underline `(:style wave :color ,red)    :background base3)
   (flycheck-warning :underline `(:style wave :color ,yellow) :background base3)
   (flycheck-info    :underline `(:style wave :color ,blue)   :background base3)
   ;;;; dired
   (dired-directory :foreground cyan)
   (diredfl-date-time :foreground blue)
   (diredfl-number :foreground green)
   (dired-marked :foreground yellow)
   (dired-symlink :foreground blue)
   (dired-header :foreground blue)
   ;;;; helm
   (helm-swoop-target-line-face :foreground magenta :inverse-video t)
   ;;;; highlight-thing
   (highlight-thing :background (doom-lighten dark-blue 0.03) :distant-foreground fg-alt)
   ;;;; highlight-symbol
   (highlight-symbol-face :background (doom-lighten blue 0.03) :distant-foreground fg-alt)
   ;;;; ivy
   (ivy-current-match :background bg-alt2)
   (ivy-subdir :background nil :foreground cyan)
   (ivy-action :background nil :foreground cyan)
   (ivy-grep-line-number :background nil :foreground cyan)
   (ivy-minibuffer-match-face-1 :background nil :foreground yellow)
   (ivy-minibuffer-match-face-2 :background nil :foreground yellow)
   (ivy-minibuffer-match-highlight :foreground cyan)
   (counsel-key-binding :foreground cyan)
   ;;;; ivy-posframe
   (ivy-posframe :background base3)
   (ivy-posframe-border :background base1)
   ;;;; LaTeX-mode
   (font-latex-math-face :foreground autumnGreen)
   ;;;; magit
   (magit-section-heading             :foreground cyan :weight 'bold)
   (magit-branch-current              :underline green :inherit 'magit-branch-local)
   (magit-diff-hunk-heading           :background base3 :foreground fg-alt)
   (magit-diff-hunk-heading-highlight :background bg-alt2 :foreground fg)
   (magit-diff-context                :foreground base3 :foreground fg-alt)
   ;;;; markdown-mode
   (markdown-header-face :inherit 'bold :foreground green)
   (markdown-header-delimiter-face :foreground orange)
   (markdown-blockquote-face :inherit 'italic :foreground grey)
   (markdown-list-face :foreground grey)
   (markdown-url-face :foreground violet)
   (markdown-pre-face  :foreground cyan)
   (markdown-link-face :inherit 'underline :foreground grey)
   ((markdown-code-face &override) :background (doom-lighten base2 0.045))
   ;;;; mu4e-view
   (mu4e-header-key-face :foreground red :weight 'bold)
   ;;;; neotree
   (neo-root-dir-face   :foreground cyan)
   (doom-neotree-dir-face :foreground cyan)
   (neo-dir-link-face   :foreground cyan)
   (neo-expand-btn-face :foreground magenta)
   ;;;; outline <built-in>
   ((outline-1 &override) :foreground red)
   ((outline-2 &override) :foreground yellow)
   ((outline-3 &override) :foreground blue)
   ((outline-4 &override) :foreground (doom-lighten violet 0.2))
   ((outline-5 &override) :foreground (doom-lighten dark-cyan 0.25))
   ((outline-6 &override) :foreground (doom-lighten violet 0.4))
   ((outline-7 &override) :foreground (doom-lighten dark-cyan 0.5))
   ((outline-8 &override) :foreground (doom-lighten violet 0.6))
   ; ((outline-1 &override) :foreground green)
   ; ((outline-2 &override) :foreground green)
   ; ((outline-3 &override) :foreground yellow)
   ; ((outline-4 &override) :foreground yellow)
   ; ((outline-5 &override) :foreground dark-yellow)
   ; ((outline-6 &override) :foreground dark-yellow)
   ;;;; org <built-in>
   (org-agenda-date-today       :foreground base7 :weight 'bold :italic t)
   (org-agenda-done             :foreground cyan)
   (org-agenda-structure        :inherit 'font-lock-comment-face)
   (org-archived                :foreground base7 :weight 'bold)
   (org-document-title          :foreground base7 :weight 'bold)
   (org-drawer                  :foreground lotusGray2)
   (org-block                   :background base1 :extend nil)
   (org-block-begin-line        :background lotusInk1 :extend nil)
   (org-block-end-line          :background lotusInk1 :extend nil)
   (org-date                    :foreground blue :underline t)
   (org-deadline-announce       :foreground red)
   (org-document-info           :foreground waveBlue2)
   (org-document-title          :foreground dark-blue)
   (org-done                    :foreground cyan :weight 'bold :bold t)
   (org-drawer                  :foreground dark-blue)
   (org-ellipsis                :foreground cyan)
   (org-footnote                :foreground cyan :underline t)
   (org-verbatim               :foreground lotusGray :background base0)
   (org-formula                 :foreground yellow)
   (org-headline-done           :foreground cyan)
   (org-latex-and-related       :foreground green)
   (org-level-1                 :foreground "#E46876" :weight 'bold :height '1.6)
   (org-level-2                 :foreground "#FFA066" :weight 'bold :height '1.4)
   (org-level-3                 :foreground "#E6C384" :weight 'bold :height '1.2)
   (org-level-4                 :foreground "#87A987")
   (org-level-5                 :foreground "#7E9CD8")
   (org-level-6                 :foreground waveBlue1)
   (org-level-7                 :foreground oniViolet)
   (org-level-8                 :foreground lotusWhite5)
   (org-link                    :foreground crystalBlue :underline t)
   (org-scheduled               :foreground yellow)
   (org-scheduled-previously    :foreground red)
   (org-scheduled-today         :foreground blue)
   (org-sexp-date               :foreground waveBlue2 :underline t)
   (org-table                   :foreground lotusGray)
   (org-tag                     :bold t :weight 'bold)
   (org-time-grid               :foreground orange)
   (org-todo                    :foreground red :weight 'bold :bold t)
   (org-upcoming-deadline       :inherit 'font-lock-keyword-face)
   (org-warning                 :foreground red :weight 'bold :bold t)
   ;;;; org-habit
   (org-habit-clear-face          :background waveBlue2)
   (org-habit-clear-future-face   :background blue)
   (org-habit-ready-face          :background green)
   (org-habit-ready-future-face   :background green)
   (org-habit-alert-face          :background yellow)
   (org-habit-alert-future-face   :background yellow)
   (org-habit-overdue-face        :background red)
   (org-habit-overdue-future-face :background red)
   (org-list-dt                   :foreground crystalBlue)
   (org-meta-line                 :foreground waveBlue2)
   ;;;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face :foreground orange)
   (rainbow-delimiters-depth-2-face :foreground magenta)
   (rainbow-delimiters-depth-3-face :foreground green)
   (rainbow-delimiters-depth-4-face :foreground blue)
   ;;;; show-paren <built-in>
   ((show-paren-match &override) :foreground 'unspecified :background base5 :bold t)
   ((show-paren-mismatch &override) :foreground 'unspecified :background "red")
   ;;;; swiper
   (swiper-line-face :background bg-alt2)
   ;;;; undo-tree
   (undo-tree-visualizer-active-branch-face :foreground cyan)
   (undo-tree-visualizer-current-face :foreground yellow)
   ;;;; vimish-fold
   ((vimish-fold-overlay &override) :inherit 'font-lock-comment-face :background bg-alt2 :weight 'light)
   ((vimish-fold-mouse-face &override) :foreground "white" :background yellow :weight 'light)
   ((vimish-fold-fringe &override) :foreground magenta :background magenta)
   ;;;; web-mode
   (web-mode-html-tag-bracket-face :foreground blue)
   (web-mode-html-tag-face         :foreground cyan)
   (web-mode-html-attr-name-face   :foreground cyan)
   (web-mode-json-key-face         :foreground green)
   (web-mode-json-context-face     :foreground cyan)
   ;;;; which-key
   (which-key-key-face                   :foreground teal)
   (which-key-group-description-face     :foreground red)
   (which-key-command-description-face   :foreground green)
   (which-key-local-map-description-face :foreground orange))

  ;;;; Base theme variable overrides
  ;; ()
  )

(provide 'kanagawa-dark-theme)
;;; kanagawa-dark-theme.el ends here
