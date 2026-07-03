(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
         :ref nil :depth 1 :inherit ignore
         :files (:defaults "elpaca-test.el" (:exclude "extensions"))
         :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
 (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
    ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
        ,@(when-let* ((depth (plist-get order :depth)))
            (list (format "--depth=%d" depth) "--no-single-branch"))
        ,(plist-get order :repo) ,repo))))
    ((zerop (call-process "git" nil buffer t "checkout"
     (or (plist-get order :ref) "--"))))
    (emacs (concat invocation-directory invocation-name))
    ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
     "--eval" "(byte-recompile-directory \".\" 0 'force)")))
    ((require 'elpaca))
    ((elpaca-generate-autoloads "elpaca" repo)))
     (progn (message "%s" (buffer-string)) (kill-buffer buffer))
   (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
;; (elpaca example-package)
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

(provide 'elpaca-setup)

;;; elpaca-setup.el ends here

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
          evil-want-keybinding nil
          evil-vsplit-window-right t
          evil-split-window-below t
       evil-want-C-u-scroll t ;; override emacs-like use of C-u to repeat
          evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
    (evil-mode))

(use-package evil-collection
  :after evil
  :config
  ;; Do not uncomment this unless you want to specify each and every mode
  ;; that evil-collection should works with.  The following line is here 
  ;; for documentation purposes in case you need it.  
  ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
  (evil-collection-init))

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
  (setq org-return-follows-link  t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)
(setq tab-bar-close-button-show nil)       ;; hide tab close / X button
(setq tab-bar-new-tab-choice "*dashboard*");; buffer to show in new tabs
(setq-default indent-tabs-mode nil) ;; use spaces instead of tabs
;; (global-display-line-numbers-mode nil)
(global-visual-line-mode t)

;; dired buffer listing options from ls
(setq dired-listing-switches "-lh")
;; truncate long visual lines in dired buffers
(add-hook 'dired-mode-hook (lambda () (setq truncate-lines t)))

(defun my/tab-bar-auto-hide ()
  "Automatically hide tab-bar when there's only one tab."
  (if (= (length (tab-bar-tabs)) 1)
      (tab-bar-mode -1)
    (tab-bar-mode 1)))

(add-hook 'tab-bar-tab-post-open-hook #'my/tab-bar-auto-hide)
(add-hook 'tab-bar-tab-pre-close-hook #'my/tab-bar-auto-hide)

(defvar my/tab-bar-icons
  '((org-mode . "\xf0726")
    (python-mode . "\xe73c")
    (inferior-python-mode . "\xe73c")
    (ess-r-mode . "\xf07d4")
    (inferior-ess-r-mode . "\xf07d4")
    (emacs-lisp-mode . "\xe628")
    (lisp-interaction-mode . "\xe628")
    (markdown-mode . "\xf48a")
    (text-mode . "\xf0219")
    (dired-mode . "\xf021b")
    (vterm-mode . "\xf489")
    (term-mode . "\xf489")
    (shell-mode . "\xf489")
    (eshell-mode . "\xf489")
    (fundamental-mode . "\xf0219")
    (message-mode . "\xf0361")
    (special-mode . "\xf0361")
    (help-mode . "\xf02d7")
    (prog-mode . "\xf0134"))
  "Mapping of major modes to Nerd Font icons (using Unicode codepoints).")

(defun my/tab-bar-get-icon-for-buffer (buffer)
  "Get icon for BUFFER based on its major mode."
  (if (bufferp buffer)
      (with-current-buffer buffer
        (or (cdr (assoc major-mode my/tab-bar-icons))
            (cdr (assoc (get major-mode 'derived-mode-parent) my/tab-bar-icons))
            "\xf0219"))
    "\xf0219"))

(defun my/tab-bar-tab-name-format (tab i)
  "Format tab name with icon, index, and truncated name."
  (let* ((tab-bar-separator "")
         (current-p (eq (car tab) 'current-tab))
         (tab-index (number-to-string i))
         (tab-buffer (alist-get 'buffer tab))
         (buf (cond
               ((bufferp tab-buffer) tab-buffer)
               ((stringp tab-buffer) (get-buffer tab-buffer))
               (current-p (window-buffer))
               (t nil)))
         (name (or (and (bufferp buf) (buffer-name buf))
                   (alist-get 'name tab)
                   "unnamed"))
         (max-len 20)
         (truncated-name (if (> (length name) max-len)
                             (concat (substring name 0 max-len) "…")
                           name))
         (icon (my/tab-bar-get-icon-for-buffer buf))
         (modified-p (and (bufferp buf)
                          (buffer-modified-p buf)))
         (modified-indicator (if modified-p "●" "")))
    (concat
     (propertize (concat " " tab-index " " icon " ")
                 'face (if current-p 'tab-bar-tab 'tab-bar-tab-inactive))
     (propertize truncated-name
                 'face (if current-p 'tab-bar-tab 'tab-bar-tab-inactive))
     (propertize (concat modified-indicator " ")
                 'face (if current-p 
                          'tab-bar-tab
                        'tab-bar-tab-inactive)))))

(setq tab-bar-tab-name-format-function #'my/tab-bar-tab-name-format)
(setq tab-bar-auto-width nil)
(setq tab-bar-tab-name-truncated-max 25)

;; Enable tab-bar-mode initially
(tab-bar-mode 1)
(my/tab-bar-auto-hide)

(defun insert-today-date ()
  "Insert today's date at point in YYYY-MM-DD format."
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

;; save temp files to ~/.config/emacs/auto-save
;; (setq auto-save-file-name-transforms
          ;; `((".*" ,(concat user-emacs-directory "auto-save/") t))) 
(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
  (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
  (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
  (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
  (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'kanagawa t)

  (use-package doom-themes
    :ensure t
    :config
    ;; (load-theme 'doom-one t)
    (setq doom-themes-enable-bold t
   doom-themes-enable-italic t)
    (doom-themes-org-config))
  ;; solaire darkens non-standard buffers' backgrounds
  ;; (use-package solaire-mode
  ;;   :ensure t
  ;;   :config
  ;;   (solaire-global-mode +1))
  ;; ;; doom's fancy modeline
  (use-package doom-modeline
    :ensure t
    :init (doom-modeline-mode 1)
    :config
    (setq doom-modeline-env-enable-python t)
    (setq doom-modeline-env-enable-R t)
    (setq doom-modeline-env-enable-julia t)
    (setq doom-modeline-height 18))

(set-face-attribute 'default nil
       :font "Liga SFMono Nerd Font"
       ;; height = 10*point size
       :height 160
       :weight 'medium)
(set-face-attribute 'variable-pitch nil
       :font "CMU Serif"
       :height 1.0
       :weight 'medium)
(set-face-attribute 'fixed-pitch nil
       :font "Liga SFMono Nerd Font"
       :height 0.6
       :weight 'medium)
  ;; italicizes commented text and keywords
  (set-face-attribute 'font-lock-comment-face nil
        :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil
        :slant 'italic)
  ;;sets default font on all graphical frames after restarting emacs
  ;; (add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-10"))

  ;;set default line spacing
  ;; (setq-default line-spacing 0.08)

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Welcome to Emacs")
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents . 5)
                        (projects . 5)
                        (bookmarks . 3)
                        (agenda . 3)
                        (registers . 3)))
  ;; (dashboard-modify-heading-icons '((recents . "file-text")
  ;;                                  (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package rainbow-mode
  :ensure t
  :hook (org-mode prog-mode))

(use-package olivetti
  :ensure t
  :hook (org-mode)
  :config
  (setq olivetti-body-width 100))

(use-package company
  :defer 2
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))
(set (make-local-variable 'company-backends) '((company-yasnippet company-capf company-keywords)))

(use-package company-box
  :after company
  :hook (company-mode . company-box-mode))

;; Ido modes
(fido-vertical-mode t)
;; (icomplete-vertical-mode t)

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1))

;; weight by frequency
(setq company-transformers '(company-sort-by-occurrence))

;; Add yasnippet support for all company backends
;; https://github.com/syl20bnr/spacemacs/pull/179
(defvar company-mode/enable-yas t "Enable yasnippet for all backends.")

(defun company-mode/backend-with-yas (backend)
  (if (or (not company-mode/enable-yas) (and (listp backend)    (member 'company-yasnippet backend)))
  backend
(append (if (consp backend) backend (list backend))
        '(:with company-yasnippet))))

(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

(use-package perspective
  :init
  (persp-mode)
  :custom
  (persp-mode-prefix-key (kbd "C-x p"))
  :config
  (setq switch-to-prev-buffer-skip
      (lambda (win buff bury-or-kill)
        (not (persp-is-current-buffer buff)))))

(use-package projectile
  :disabled
  :config
  (projectile-mode 1))

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)

(use-package vterm
  :ensure t)

(use-package vterm-toggle
  :ensure t
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
     '((lambda (buffer-or-name _)
     (let ((buffer (get-buffer buffer-or-name)))
 (with-current-buffer buffer
   (or (equal major-mode 'vterm-mode)
       (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
  (display-buffer-reuse-window display-buffer-at-bottom)
  ;;(display-buffer-reuse-window display-buffer-in-direction)
  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
  ;;(direction . bottom)
  ;;(dedicated . t) ;dedicated is supported in emacs27
  (reusable-frames . visible)
  (window-height . 0.3)))
  )

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
 which-key-sort-order #'which-key-key-order-alpha
 which-key-sort-uppercase-first nil
 which-key-add-column-padding 1
 which-key-max-display-columns nil
 which-key-min-display-lines 6
 which-key-side-window-slot -10
 which-key-side-window-max-height 0.25
 which-key-idle-delay 0.8
 which-key-max-description-length 25
 which-key-allow-imprecise-window-fit nil
 which-key-separator "  " ))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
    ("jpg" . "sxiv")
    ("png" . "sxiv")
    ("mkv" . "mpv")
    ("mp4" . "mpv"))))

(defun my/org-wrap-with (char)
  "Wraps the selected region with CHAR. 
If no region is selected, inserts CHAR CHAR and places cursor between them."
  (if (use-region-p)
      (let ((beg (region-beginning))
            (end (region-end)))
        (save-excursion
          (goto-char end)
          (insert char)
          (goto-char beg)
          (insert char)))
    (insert char char)
    (backward-char (length char))
    (evil-insert-state)))

(defun my/org-bold ()
  "Wrap region in *bold*."
  (interactive)
  (my/org-wrap-with "*"))

(defun my/org-italics ()
  "Wrap region in /italics/."
  (interactive)
  (my/org-wrap-with "/"))

(defun my/org-underline ()
  "Wrap region in _underline_."
  (interactive)
  (my/org-wrap-with "_"))

(defun my/org-code ()
  "Wrap region in =code=."
  (interactive)
  (my/org-wrap-with "="))

(defun my/org-monospace ()
  "Wrap region in ~monospace~."
  (interactive)
  (my/org-wrap-with "~"))

(defun my/org-insert-link (url)
  "Wrap selected text (description) in a link to URL.
Syntax: [[URL][Selection]]
If no region is active, inserts [[URL][]] and places cursor for description."
  (interactive "sLink URL: ")
  (if (use-region-p)
      (let ((beg (region-beginning))
            (end (region-end))
            (selection (buffer-substring-no-properties (region-beginning) (region-end))))
        (delete-region beg end)
        (insert (format "[[%s][%s]]" url selection)))
    (insert (format "[[%s][]]" url))
    (backward-char 2)))

(use-package general
  :ensure t
  :config
  (general-evil-setup)
  
  (general-define-key
   :states '(normal visual)
   :keymaps 'override
   "g c c" '(comment-line :wk "Comment Line"))
  
  ;; set space bar as global leader key
  (general-create-definer dy/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "C-SPC") ;; access leader in insert mode
  
  (general-define-key
   :keymaps 'override
   "M-N" '(make-frame :wk "Open new frame")
   "M-w" '(delete-window :wk "Hide window")
   "M-q" '(delete-buffer-and-window :wk "Quit buffer and window")
   "M-." '(dired :wk "Dired")
   "M-s" '(save-buffer :wk "Save buffer")
   "M-z" '(undo :wk "Undo")
   "M-Z" '(undo-redo :wk "Redo"))
  
  (dy/leader-keys
    "SPC" '(execute-extended-command :wk "M-x")
    "c s" '(cheat-sheet :wk "Cheat Sheet"))
  
  (dy/leader-keys
    "f f" '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "f i" '(imenu :wk "Find index")
    "f r" '(recentf :wk "Find recent files")
    "f s" '(affe-grep :wk "Find string in current project"))
  
  (general-create-definer dy/org-g-def
    :states '(normal)
    :prefix "g"
    :keymaps 'override)
  (dy/org-g-def
   "b" #'my/org-bold
   "i" #'my/org-italics
   "s" #'my/org-underline
   "=" #'my/org-code
   "`" #'my/org-monospace
   "l" #'my/org-insert-link)

  (dy/leader-keys
    "a" '(:ignore t :wk "AI tools")
    "a i" '(gptel :wk "Open GPTel")
    "a m" '(gptel-menu :wk "GPTel Menu")
    "a t" '(gptel-tools :wk "Tools menu for GPTel"))

  (dy/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b q" '(kill-this-buffer :wk "Kill buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b s" '(switch-to-buffer :wk "Switch buffers")
    "b S" '(persp-switch-to-buffer :wk "Switch buffers (from any perspective")
    "b i" '(ibuffer :wk "Buffer Index"))
  
  (dy/leader-keys
    "c" '(:ignore t :wk "comment")
    ;; "c c" '(comment-line :wk "comment line")
    "c r" '(comment-region :wk "comment region")
    "c b" '(comment-box :wk "comment box"))
  
  (dy/leader-keys
    "d" '(:ignore t :wk "dired")
    "d d" '(dired :wk "open dired")
    "d j" '(dired-jump :wk "open current directory")
    "d L" '(dired-jump-other-window :wk "open current directory in new window"))
  
  (dy/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate an elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e s" '(eshell :wk "Eshell"))
  
  (dy/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h k" '(describe-key :wk "Describe keybinding")
    "h v " '(describe-variable :wk "Describe variable")
    "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
  
  (dy/leader-keys
    "i" '(:ignore t :wk "Insert")
    "i t" '(insert-today-date :wk "Insert today's date"))

  (dy/leader-keys
    "m" '(:ignore t :wk "Bookmark")
    "m s" '(bookmark-set :wk "Set a bookmark")
    "m j" '(bookmark-jump :wk "Jump to a bookmark")
    "m t t" '(org-todo :wk "Mark as TODO")
    "m l" '(list-bookmarks :wk "List bookmarks"))
  
  (dy/leader-keys
    "o" '(:ignore t :wk "Org")
    "o a" '(org-agenda :wk "Org agenda")
    "o e" '(org-export-dispatch :wk "Org export dispatch")
    "o i" '(:ignore t :wk "I")
    ;; "o i t" '(org-item-toggle :wk "Toggle item")
    ;; "o i d" '(org-id-get-create :wk "create org ID")
    "o t" '(org-todo :wk "Org todo")
    "o b t" '(org-babel-tangle :wk "Org babel tangle")
    "o T" '(org-todo-list :wk "Org todo list"))
  
  (dy/leader-keys
    "o d" '(:ignore t :wk "Dates/times")
    "o d t" '(org-time-stamp :wk "Org time stamp"))
  
  (dy/leader-keys
    "p" '(:ignore :wk "Project")
    "p f" '(project-find-file :wk "Find files in current project")
    "p d" '(project-dired :wk "Open dired for project directory")
    "p s" '(persp-switch :wk "Switch Perspectives")
    "p o" '(project-switch-project :wk "Switch or open project")
    "p b" '(project-list-buffers :wk "List project buffers")
    "p k" '(project-kill-buffers :wk "Close all project buffers")
    )
  
  (dy/leader-keys
    "r" '(:ignore :wk "R")
    "r d" '(ess-rdired  :wk "open R object directory"))
  
  (dy/leader-keys
    "s" '(:ignore :wk "snippets")
    "s n" '(yas-new-snippet :wk "new snippet"))
  
  (dy/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t b" '(org-hide-block-all :wk "Toggle org blocks")
    "t c" '(quick-calc :wk "Toggle calculator")
    "t i" '(org-toggle-inline-images :wk "Toggle inline images")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(toggle-truncate-lines :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm")
    "t m p" '(mixed-pitch-mode :wk "Toggle mixed-pitch mode")
    "t z" '(olivetti-mode :wk "Toggle olivetti (zen) mode"))
  
  (dy/leader-keys
    "v" '(:ignore t :wk "Vulpea")
    "v f" '(vulpea-find :wk "Vulpea find note")
    "v i" '(vulpea-insert :wk "Insert note"))
    ;; "v s" '(magit-status :wk "Git status")
    ;; "v r" '(vc-region-history :wk "Version history of region"))
  
  
  (dy/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w q" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  (general-create-definer dy/tab-bar
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "C-TAB")

  (dy/tab-bar
   "s" '(tab-bar-switch-to-tab :wk "Switch tab by name")
   "d" '(tab-bar-detach :wk "Detach tab to new (OS) window"))
   
  )

  (global-set-key (kbd "C-=") 'text-scale-increase)
  (global-set-key (kbd "C--") 'text-scale-decrease)
  (global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
  (global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(setq org-agenda-files (list "~/Org"))

(use-package org-journal
  :ensure t
  :defer t
  :init
  ;; Change default prefix key; needs to be set before loading org-journal
  (setq org-journal-prefix-key "<SPC> j")
  :config
  (setq org-journal-dir "~/Org/journals/")
  (setq org-journal-file-format "%Y_%m_%d.org"))

;; Language support
(org-babel-do-load-languages
 'org-babel-load-languages
 '((julia . t)
   (latex . t)
   (shell . t)
   (R . t)
   (js . t)))

;; org-tempo is not enabled by default,
;;allows a quick way to add source blocks.
(require 'org-tempo)

(use-package toc-org
:ensure t
:commands toc-org-enable
:init (add-hook 'org-mode-hook 'toc-org-enable))

(use-package org-modern
  :ensure t
  :hook org-mode
  :config
  (setq org-modern-star 'replace)
  (custom-set-variables
    '(org-modern-replace-stars "◉○❖◈◇"))
  (custom-set-variables
   '(org-modern-checkbox
     '((?X . #("□✔" 0 2 (composition ((2)))))
      (?\s . "□")
      (?- . #("□–" 0 2 (composition ((2))))))))
  (custom-set-variables
   '(org-modern-list
    '((?+ . "•")
      (?- . "◦")
      (?* . "∗"))))
  (custom-set-variables
   '(org-modern-radio-target '(" ✒ " t " ")))
  (custom-set-variables
   '(org-modern-internal-target '(" ↪ " t " ")))
  (setq org-modern-symbol '"Iosevka")
  (setq org-modern-keyword
 (quote (("title" . "📓") (t . t)))))
    ;; (("title" . "📓") (t . t))
    ;; (("date" . "📅") (t . t))
    ;; (("author" . "🖎") (t . t))

(setq electric-indent-mode -1)
(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation 0)

(setq org-hide-emphasis-markers t)

(use-package mixed-pitch
  :hook
  (org-mode . mixed-pitch-mode))

(setq org-ellipsis "⇥")

;; (use-package org-latex-preview
;;   :ensure t
;;   :config
;;   (plist-put org-latex-preview-appearance-options
;;       :page-width 0.8)
;;   (setq org-latex-preview-live t))

(setq org-cite-global-bibliography '("~/betterbibtex.bib"))

;; (use-package citar
;;   :custom
;;   (citar-bibliography '("~/zotero-library.bib"))
;;   ;; Use `citar' with `org-cite'
;;   (org-cite-insert-processor 'citar)
;;   (org-cite-follow-processor 'citar)
;;   (org-cite-activate-processor 'citar)
;;   :hook
;;   (LaTeX-mode . citar-capf-setup)
;;   (org-mode . citar-capf-setup))
;;
;; (use-package citar-embark
;;   :after citar embark
;;   :no-require
;;   :config (citar-embark-mode))
;;
;; (use-package embark
;;   :ensure t)

(use-package cond-let
  :ensure (:host github :repo "tarsius/cond-let"))

(use-package org-roam
  :ensure t
  :after cond-let
  :demand t
  :custom
  (org-roam-directory "~/Org")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d>-${slug}.org" "#+TITLE: ${title}\n#+DATE: %T\n")
      :unnarrowed t)))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup))

(use-package vulpea
  :ensure t
  :init
  (vulpea-db-autosync-mode +1) ;; enable auto-sync
  :custom
  (vulpea-db-sync-directories '("~/Org/"))
  (vulpea-db-location "vulpea.db" "~/Org/")
  (vulpea-default-notes-directory "~/Org/pages/")
  (vulpea-create-default-template
   '(:tags ("inbox")
           :head "#+created: %<[%Y-%m-%d]>"))
  (vulpea-buffer-alias-property "ROAM_ALIASES"))

;; transient required by gptel
(use-package transient
  :ensure (:ref "v0.10.1")
  :demand t)

(use-package gptel
  ;; I was having conflicting versions with elpaca until I set this
  ;; :load-path "elpa/gptel-0.9.9/" 
  :ensure t
  :after transient
  :config
  ;; jump cursor to next prompt line
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
   ;; setting the gptel-api-key with the host name works here
  (setq auth-sources '("~/.authinfo"))
  (setq gptel-api-key
 (auth-source-pick-first-password :host "openrouter.ai"))
  (setq gptel-default-mode 'org-mode) ;; chat in org-mode or markdown
  (setq gptel-prompt-prefix-alist
   '((org-mode . " :") (text-mode . "💬 :")))
  (setq gptel-response-prefix-alist
   '((org-mode . " ") (text-mode . "> 🤖 ")))
  (gptel-make-openai "LMStudio"
    :protocol "http"
    :host "localhost:1234"
    :stream t
    ;; :context t
    ;; :sources t
    :models '(qwen3-14b-mlx
              qwen3-4b-thinking-2507
              qwen3-4b-2507
              qwen3-30b-a3b
              gemma-3n-e4b
              qwen3-14b))
  (setq gptel-model   'google/gemini-3-flash-preview
      gptel-backend
      (gptel-make-openai "OpenRouter"
        :host "openrouter.ai"
        :endpoint "/api/v1/chat/completions"
        :stream t
        :key gptel-api-key ; function that returns key from .authinfo
        :models (m/augment-openrouter-models-list
                 '(google/gemini-2.5-flash
                   google/gemini-3-flash-preview
                   google/gemini-3-pro-preview
                   anthropic/claude-sonnet-4.5
                   anthropic/claude-opus-4.5
                   openai/gpt-5-mini
                   openai/gpt-5
                   z-ai/glm-4.6
                   moonshotai/kimi-k2-0905
                   qwen/qwen3-vl-235b-a22b-thinking
                   qwen/qwen3-vl-235b-a22b-instruct
                   deepseek/deepseek-v3.2)))))

(defun m--fetch-openrouter-models ()
  "Fetch and parse the OpenRouter models API synchronously.
Return an alist of (ID-STRING . raw-model-plist) entries."
  (let ((url-request-extra-headers '(("Accept" . "application/json"))))
    (with-current-buffer
        (url-retrieve-synchronously "https://openrouter.ai/api/v1/models" t t 15)
      (goto-char (point-min))
      (re-search-forward "\n\n") ;; skip HTTP headers
      (let* ((raw (buffer-substring-no-properties (point) (point-max)))
             (data (json-parse-string raw
                                      :object-type 'plist
                                      :array-type 'list
                                      :null-object nil
                                      :false-object :json-false)))
        (mapcar (lambda (m) (cons (plist-get m :id) m))
                (plist-get data :data))))))

(defun m--guess-capabilities (desc)
  "Heuristically guess capabilities from DESC string."
  (let ((d (downcase (or desc "")))
        caps)
    (when (string-match-p "tool" d)    (push 'tool-use caps))
    (when (string-match-p "reason" d)  (push 'reasoning caps))
    (when (string-match-p "image" d)   (push 'media caps))
    (when (string-match-p "json" d)    (push 'json caps))
    (when (string-match-p "url" d)     (push 'url caps))
    (nreverse caps)))

(defun m--convert-openrouter-to-gptel (m)
  "Convert OpenRouter model plist M into gptel--openai-models-style plist."
  (let* ((desc (plist-get m :description))
         (ctx (or (plist-get m :context_length)
                  (plist-get (plist-get m :top_provider) :context_length)))
         (pricing (plist-get m :pricing))
         (in (and pricing
                  (* 1e6 (string-to-number (or (plist-get pricing :prompt) "0")))))
         (out (and pricing
                   (* 1e6 (string-to-number (or (plist-get pricing :completion) "0"))))))
    (append (list :description desc)
            (when ctx (list :context-window (/ ctx 1000.0)))
            (when in (list :input-cost in))
            (when out (list :output-cost out))
            (let ((caps (m--guess-capabilities desc)))
              (when caps (list :capabilities caps))))))

(defun m/augment-openrouter-models-list (ids)
  "Augment model IDS using the OpenRouter API.
Returns a list of (symbol . plist).  If a model is missing, returns (id)."
  (let* ((all (m--fetch-openrouter-models))
         (tbl (make-hash-table :test 'equal)))
    (dolist (m all)
      (puthash (car m) (cdr m) tbl))
    (mapcar
     (lambda (id)
       (let* ((id-str (if (symbolp id) (symbol-name id) id))
              (m (gethash id-str tbl)))
         (if m
             (cons (intern id-str) (m--convert-openrouter-to-gptel m))
           (list (intern id-str)))))
     ids)))

;;;; My Local AI Assistant
;;;
;;; This section contains the functions for a local AI assistant that
;;; uses gptel for the brain, and will later use local TTS/STT.

(defcustom my-assistant-backend 'Ollama
  "The `gptel-backend' to use for the assistant."
  :type '(symbol)
  :group 'gptel)

(defcustom my-assistant-model "qwen3-14b"
  "The `gptel-model' to use for the assistant."
  :type '(string)
  :group 'gptel)

(defun my-assistant-ask (prompt)
  "Send PROMPT to the assistant's LLM and return the response synchronously.
This function will block until the LLM response is received."
  (let ((response-text nil))
    ;; Call the asynchronous function with our custom callback.
    (gptel-request prompt
                   :callback (lambda (response _info)
                               ;; This runs when the answer arrives.
                               (setq response-text (or response ""))))
    ;; Wait for the callback to set the `response-text` variable.
    (while (not response-text)
      (accept-process-output nil 0.1))
    ;; Return the final result.
    response-text))
(defcustom my-assistant-piper-model "en_US-kusal-medium"
  "The Piper voice model to use for TTS."
  :type 'string
  :group 'gptel)

(defcustom my-assistant-piper-data-dir nil
  "Directory containing Piper voice models. If nil, uses current directory."
  :type '(choice (const :tag "Current directory" nil)
                 (directory :tag "Custom directory"))
  :group 'gptel)

(setq my-assistant-piper-data-dir "~/.local/share/piper-voices")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; My Assistant - Core Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-assistant-speak (text)
  "Speak TEXT using Piper TTS engine with robust audio playback."
  (message "ASSISTANT (speak): Requesting TTS for \"%s...\"" (substring text 0 (min 30 (length text))))
  (unless (executable-find my-assistant-piper-executable)
    (error "Cannot find Piper executable: '%s'. Check =my-assistant-piper-executable= and Emacs =exec-path="
           my-assistant-piper-executable))
  (let* ((temp-file (make-temp-file "piper-tts-" nil ".wav"))
         (data-dir-arg (when (and my-assistant-piper-data-dir (file-directory-p my-assistant-piper-data-dir))
                         (list "--data-dir" (expand-file-name my-assistant-piper-data-dir))))
         (piper-args (append (list "-m" my-assistant-piper-model "-f" temp-file)
                             data-dir-arg
                             (list "--" text))))
    (unwind-protect
        (let* ((piper-output-buffer (generate-new-buffer "*piper-output*"))
               (exit-code (apply #'call-process my-assistant-piper-executable nil piper-output-buffer t piper-args)))
          (if (/= exit-code 0)
              (progn
                (display-buffer piper-output-buffer)
                (error "Piper process failed with exit code %s. See *piper-output* buffer." exit-code))
            (kill-buffer piper-output-buffer)
            (when (file-exists-p temp-file)
              (message "Piper generated audio: %s" temp-file)
              (if (executable-find "play")
                  (let ((play-output-buffer (generate-new-buffer "*play-output*")))
                    (message "Attempting to play audio with 'play'...")
                    (let ((play-exit-code (call-process "play" nil play-output-buffer t temp-file)))
                      (if (/= play-exit-code 0)
                          (progn
                            (display-buffer play-output-buffer)
                            (error "Sox 'play' process failed with exit code %d. See *play-output* buffer." play-exit-code))
                        (kill-buffer play-output-buffer)
                        (message "Audio playback finished."))))
                (error "Sox 'play' command not found. Cannot play audio."))))
          )
      (when (file-exists-p temp-file)
        (delete-file temp-file)))))

;; --- Phase 3 Placeholder ---
(defun my-assistant-listen ()
  "Listen for audio and return the transcribed text. (Placeholder)"
  (let ((input (read-from-minibuffer "ASSISTANT (listen): ")))
    (message "ASSISTANT (listen): You said '%s'" input)
    input))

;; --- The Main Interactive Function ---
(defun my-assistant-interactive ()
  "Ask the assistant a question and get a spoken response."
  (interactive)
  (let* ((question (read-from-minibuffer "Ask your assistant: "))
         (answer (my-assistant-ask question)))
    (my-assistant-speak answer)))

(use-package ess
  :ensure t
  :config
  (load "ess-autoloads")
  (load-library "ob-R")
  (load-library "ob-julia")
  (setq org-confirm-babel-evaluate nil))

(use-package auctex
  :ensure t
  :config
  (setq TeX-PDF-mode t))
(setq +latex-viewers '(pdf-tools))

;; (use-package cdlatex
;;   :ensure t
;;   :hook (org-mode . org-cdlatex-mode)
;;   :bind ("<f5>" . cdlatex-math-symbol)
;;   :config
;;   ;; Unbind the backtick key
;;   (define-key cdlatex-mode-map (kbd "`") nil))

(use-package pdf-tools
  :ensure t
  :load-path "~/.config/emacs/elpa/pdf-tools-1.1.0")
