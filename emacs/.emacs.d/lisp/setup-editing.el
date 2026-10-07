;;; setup-editing.el --- Emacs configs for core editing features -*- lexical-binding: t -*-

(use-package helm
  :ensure t
  :config
  (setq helm-autoresize-max-height 20)
  (helm-autoresize-mode t)
  (global-set-key (kbd "C-x C-r") #'helmx-recentf)
  (global-set-key (kbd "M-x") 'helm-M-x))

(global-set-key (kbd "M-i") 'imenu)

(setq delete-selection-mode t)

(setq shift-select-mode nil)

(use-package vundo
  :ensure t)

(provide 'setup-editing)
