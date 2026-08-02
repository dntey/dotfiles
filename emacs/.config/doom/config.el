;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; ── Fonts ────────────────────────────────────────────────────────────────────
;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font                (font-spec :family "SFMono Nerd Font"
                                          :size 18 :weight 'medium)
      ;; doom-variable-pitch-font (font-spec :family "Georgia"
      ;;                                     :size 14 :weight 'medium)
      doom-big-font            (font-spec :family "SFMono Nerd Font"
                                          :size 24))

;; ── Theme ─-───────────────────────────────────────────────────────────────────
;; avoid asking for whether all local themes are safe or not
(setq custom-safe-themes t)

(load-theme 'kanagawa-dark)

(after! doom-themes
  (setq doom-themes-enable-bold   t
        doom-themes-enable-italic t)
  (doom-themes-org-config))

;; Italicise comments and keywords (matches original config)
(after! font-lock
  (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil :slant 'italic))

;; --- Basic Settings -----------------------------------------------------------


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Disable line numbers for prose and special buffers
(add-hook! '(org-mode-hook markdown-mode-hook text-mode-hook magit-mode-hook vterm-mode-hook)
  (setq display-line-numbers nil))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Org/")

;;; ═══════════════════════════════════════════════════════════════════════════
;;; Tweaks taken from
;;; https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
;;; ═══════════════════════════════════════════════════════════════════════════

;; skip fontification during input
(setq redisplay-skip-fontification-on-input t)

;; Save clipboard before killing
(setq save-interprogram-paste-before-kill t)
;; remove duplicate entries in killring
(setq kill-do-not-save-duplicates t)

;; Reversible C-x 1 toggle
(winner-mode +1)

(defun toggle-delete-other-windows ()
  "Delete other windows in frame if any, or restore previous window config."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))

(global-set-key (kbd "C-x 1") #'toggle-delete-other-windows)

;; ── keybindings ───────────────────────────────────────────
(map! :leader
      :prefix ("b" . "Buffer")
      :desc "Switch buffer" "s" #'switch-to-buffer)
(unpin!)

;; ── Theme Customization (Kanagawa) ───────────────────────────────────────────

;; Visual-line-mode for prose buffers (soft wrapping)
(add-hook! '(org-mode-hook markdown-mode-hook text-mode-hook)
  (visual-line-mode +1))

;; ── Modeline ─────────────────────────────────────────────────────────────────
(after! doom-modeline
  (setq doom-modeline-height              18
        doom-modeline-env-enable-python   t
        doom-modeline-env-enable-R        t))


(setq-default indent-tabs-mode nil)
(setq-default org-hide-emphasis-markers t)

;; truncate long visual lines in dired buffers
(add-hook 'dired-mode-hook (lambda () (setq truncate-lines t)))

(use-package! org-modern
  :hook org-mode
  :init
  (setq org-modern-star 'replace)
  (setq org-modern-block-name nil)
  (custom-set-variables
   '(org-modern-replace-stars "❖◉○◈◇")
   '(org-modern-checkbox
     '((?X  . #("□✔" 0 2 (composition ((2)))))
       (?\s . "□")
       (?-  . #("□–" 0 2 (composition ((2)))))))
   '(org-modern-list
     '((?+ . "•")
       (?- . "◦")
       (?* . "∗")))
   '(org-modern-radio-target    '(" ✒ " t " "))
   '(org-modern-internal-target '(" ↪ " t " ")))
  (setq org-modern-symbol  "Liga SFMono Nerd Font"
        org-modern-keyword '(("title" . "📓") (t . t))))

(plist-put! +ligatures-extra-symbols
  :example       "▸"      ; or whatever symbol you prefer
  :example_end   "▴"
  :elisp         ""
  :src_block     "❯"
  :src_block_end "▴"
  :tool          "🔨"
  :tool_end      "▴"
  :think         "🧠"
  :think_end     "▴")

(after! org
  (set-ligatures! 'org-mode
    :example       "#+begin_example"
    :example_end   "#+end_example"
    :elisp         "emacs-lisp"
    :tool          "#+begin_tool"
    :tool_end      "#+end_tool"
    :think         "#+begin_reasoning"
    :think_end     "#+end_reasoning"))

;;; Note Taking — Org-Roam
;;; ═══════════════════════════════════════════════════════════════════════════

;; Provided by `:lang (org +roam2)' module
(after! org-roam
  (setq org-roam-directory            "~/Org"
        org-roam-completion-everywhere t
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :if-new (file+head "%<%Y%m%d>-${slug}.org"
                              "#+TITLE: ${title}\n#+DATE: %T\n")
           :unnarrowed t))))

;;; ═══════════════════════════════════════════════════════════════════════════
;;; Note Taking — Vulpea
;;; ═══════════════════════════════════════════════════════════════════════════

(use-package! vulpea
  :after org-roam
  :init
  (vulpea-db-autosync-mode +1)
  :custom
  (vulpea-db-sync-directories '("~/Org/" "~/Org/projects"))
  (vulpea-db-location "vulpea.db" "~/Org/")
  (vulpea-default-notes-directory "~/Org/pages/")
  (vulpea-create-default-template
   '(:filename "${slug}.org"
     :tags ("inbox")
     :head "#+created: %<[%Y-%m-%d]>"
     :properties (("CREATED" . "%<[%Y-%m-%d]>"))))
  (vulpea-buffer-alias-property "ROAM_ALIASES"))

(map! :leader
      :prefix ("v" . "Vulpea")
      :desc "Find note" "f" #'vulpea-find
      :desc "Insert note" "i" #'vulpea-insert
      :desc "Find backlink" "b" #'vulpea-find-backlink
      :desc "Add meta" "m" #'vulpea-meta-add
      :desc "Add tag" "t" #'vulpea-buffer-tags-add
      :desc "Add alias" "a" #'vulpea-buffer-alias-add)


;;; ═══════════════════════════════════════════════════════════════════════════
;;; AI — gptel
;;; ═══════════════════════════════════════════════════════════════════════════

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

(use-package transient
  ;; :ensure (:ref "v0.10.1")
  :demand t)

(use-package! gptel
  :after transient
  :config
  ;; jump cursor to next prompt line
  ;; (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
   ;; setting the gptel-api-key with the host name works here
  (setq auth-sources '("~/.authinfo"))
  (setq gptel-default-mode 'org-mode) ;; chat in org-mode or markdown
  (setq gptel-prompt-prefix-alist
        '((org-mode . ": ") (text-mode . "💬 :")))
  (setq gptel-response-prefix-alist
        '((org-mode . "-----\n> ") (text-mode . "> 🤖 ")))
  (setq gptel-highlight-methods '(margin fringe))
  (setq gptel-use-header-line t)
  (gptel-make-openai "LMStudio"
    :protocol "http"
    :host "localhost:1234"
    :stream t
    ;; :context t
    ;; :sources t
    :models '(qwen3-14b-mlx
              qwen3.6-35b-a3b
              gemma-4-26b-a4b
              gemma-4-31b-it
              gemma-3n-e4b
              qwen3-14b))
  (setq gptel-model   'z-ai/glm-5.2
      gptel-backend
      (gptel-make-openai "GPTEL"
        :host "openrouter.ai"
        :endpoint "/api/v1/chat/completions"
        :stream t
        :key (lambda ()
               (or (auth-source-pick-first-password :host "openrouter.ai")
                   (error "Gptel: could not retrieve OpenRouter key from auth-sources")))
        :models '(z-ai/glm-5.2)))

  ;; wait to augment from openrouter model list
  ;; to avoid problems with network being unavailable at startup
  (run-with-idle-timer
   3 nil
   (lambda ()
     (setq gptel-backend
           (gptel-make-openai "GPTEL"
             :host "openrouter.ai"
             :endpoint "/api/v1/chat/completions"
             :stream t
             :key (lambda ()
                    (or (auth-source-pick-first-password :host "openrouter.ai")
                        (error "Gptel: could not retrieve OpenRouter key from auth-sources")))
        :models (m/augment-openrouter-models-list
                 '(google/gemini-2.5-flash
                   google/gemini-3-flash-preview
                   google/gemini-2.5-flash-lite
                   google/gemini-3.1-pro-preview
                   anthropic/claude-sonnet-4.6
                   anthropic/claude-opus-4.6
                   z-ai/glm-4.6
                   z-ai/glm-5
                   z-ai/glm-5.2
                   moonshotai/kimi-k2.6)))))))

(gptel-agent-update)

(setq ess-R-font-lock-keywords
      '((ess-R-fl-keyword:keywords . t)
        (ess-R-fl-keyword:constants . t)
        (ess-R-fl-keyword:modifiers . t)
        (ess-R-fl-keyword:fun-defs . t)
        (ess-R-fl-keyword:assign-ops . t)
        (ess-R-fl-keyword:%op% . t)
        (ess-fl-keyword:fun-calls . t)
        (ess-fl-keyword:numbers . t)
        (ess-fl-keyword:operators . t)
        (ess-fl-keyword:delimiters . t)
        (ess-fl-keyword:= . t)
        (ess-R-fl-keyword:F&T . t)))


;;; ═══════════════════════════════════════════════════════════════════════════
;; ; change writegood-mode from enabled by default in org-mode
(remove-hook 'org-mode-hook #'writegood-mode)

;;; ── 8. System Integration ───────────────────────────────────────────────────

;; Theme Switching via DBus (Linux Only)
(when (eq system-type 'gnu/linux)
  (defvar dy:dark-theme 'kanagawa
    "Default dark theme.")

  (defvar dy:light-theme 'kanagawa-light
    "Default light theme.")

  (defun dy/theme-from-dbus (value)
    "Change the theme based on a D-Bus property."
    (load-theme (if (= 0 (car (flatten-list value)))
                    dy:light-theme
                  dy:dark-theme)
                t))

  (require 'dbus)

  ;; Set the current theme based on the system theme right now
  (dbus-call-method-asynchronously
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "Read"
   #'dy/theme-from-dbus
   "org.freedesktop.appearance"
   "color-scheme")

  ;; Listen for system theme changes
  (dbus-register-signal
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "SettingChanged"
   (lambda (path var value)
     (when (and (string-equal path "org.freedesktop.appearance")
                (string-equal var "color-scheme"))
       (dy/theme-from-dbus value)))))


;;; ═══════════════════════════════════════════════════════════════════════════
;;; Kiwix integration
;;; ═══════════════════════════════════════════════════════════════════════════
;; (require 'org-kiwix)

;; (use-package! kiwix
;;   :after org
;;   :commands (kiwix-launch-server kiwix-at-point)
;;   :bind (:map document-prefix ("w" . kiwix-at-point))
;;   :custom ((kiwix-server-type 'kiwix-serve-local)
;;            (kiwix-server-url "http://127.0.0.1")
;;            (kiwix-server-port 80)
;;            (kiwix-zim-dir (expand-file-name "/home/dante/.local/share/kiwix-desktop/wiktionary_en_all_nopic_2026-02.zim")))
;;   :hook (org-load . org-kiwix-setup-link)
;;   :init (require 'org-kiwix)
;;   :config (add-hook 'org-load-hook #'org-kiwix-setup-link))


(map! "s-n" #'make-frame)

;;;; "Prose Mode": easily toggle between my favorite settings for org-mode buffers
;; Define a minor mode to toggle prose settings globally and locally
;; (define-minor-mode my/prose-mode
;;   "Toggle `writeroom-mode', `visual-line-mode', and `org-indent-mode'."
;;   :init-value nil
;;   :global t ;; Writeroom is global, so this toggle should be too
;;   (writeroom-mode (if my/prose-mode +1 -1))
;;   (visual-line-mode (if my/prose-mode +1 -1))
;;   (when (derived-mode-p 'org-mode)
;;     (org-indent-mode (if my/prose-mode +1 -1))))

;; ;; Enable these modes by default for org and text files
;; (add-hook! '(org-mode-hook text-mode-hook)
;;   (my/prose-mode +1))

;; ;; Keybinding: "SPC t p" (toggle prose)
;; (map! :leader
;;       :desc "Toggle prose mode" "t p" #'my/prose-mode)


;;;; org-insert-special custom behavior
;; Making `i' key conditionally activate `org-edit-special' or `evil-insert' depending on context
(after! org
  (defun my/org-insert-or-edit (&optional count)
    "Enter insert state, or call `org-edit-special' if on a special element."
    (interactive "p")
    (condition-case nil
        (progn
          ;; Try to call org-edit-special
          (org-edit-special)
          ;; If we are now in a special edit buffer, switch to insert state
          (evil-insert-state))
      ;; If org-edit-special threw an error (not on a special element),
      ;; fall back to evil-insert
      (user-error (evil-insert count))))

;; Override the binding in normal state
(map! :map org-mode-map :n "I" #'my/org-insert-or-edit))

;; custom bindings for when inside `org-src' buffer
(map! :after org-src
      :map org-src-mode-map
      :n "q" #'org-edit-src-abort    ; Quit without saving
      :n "ZZ" #'org-edit-src-save)   ; "Save and Close" (like Vim)

;; Disable writeroom keybindings
(after! writeroom-mode
  (unbind-key "<leader> t z")
  (unbind-key "<leader> t Z"))

(use-package! olivetti
  :commands olivetti-mode
  :config
  (setq olivetti-body-width 120)
  :init
  (map! :leader :desc "Olivetti" "t z" #'olivetti-mode))

;; mixed-pitch is already provided by :ui zen, just add your hook
(add-hook! org-mode #'mixed-pitch-mode)

;; Enable Arabic and Bidirectional text support
(+bidi-global-mode 1)
(setq-default bidi-display-reordering t)
(setq +bidi-want-smart-fontify t)
(setq bidi-paragraph-direction 'right-to-left)

;; Set specific font for Arabic characters (change "Amiri" to your preferred font)
(set-fontset-font t 'arabic (font-spec :family "AlArabiya" :size 18))
