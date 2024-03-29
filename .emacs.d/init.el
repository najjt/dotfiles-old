(setq package-enable-at-startup nil)

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(defvar better-gc-cons-threshold 4294967269; 512mb
  "The default value to use for `gc-cons-threshold'.

If you experience freezing, decrease this.  If you experience stuttering, increase this.")

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold better-gc-cons-threshold)))

(add-hook 'emacs-startup-hook
      (lambda ()
        (if (boundp 'after-focus-change-function)
        (add-function :after after-focus-change-function
              (lambda ()
                (unless (frame-focus-state)
                  (garbage-collect))))
      (add-hook 'after-focus-change-function 'garbage-collect))
        (defun gc-minibuffer-setup-hook ()
      (setq gc-cons-threshold (* better-gc-cons-threshold 2)))

        (defun gc-minibuffer-exit-hook ()
      (garbage-collect)
      (setq gc-cons-threshold better-gc-cons-threshold))

        (add-hook 'minibuffer-setup-hook #'gc-minibuffer-setup-hook)
        (add-hook 'minibuffer-exit-hook #'gc-minibuffer-exit-hook)))

(defconst *sys/linux*
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")

(defconst *sys/mac*
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(when *sys/linux*
  (setq x-super-keysym 'meta))

(when *sys/mac*
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)
  (setq dired-use-ls-dired nil)
  (setq frame-resize-pixelwise t)
  (add-to-list 'default-frame-alist '(undecorated . t)))

(defun update-to-load-path (folder)
  "Update FOLDER and its subdirectories to `load-path'."
  (let ((base folder))
    (unless (member base load-path)
  (add-to-list 'load-path base))
    (dolist (f (directory-files base))
  (let ((name (concat base "/" f)))
    (when (and (file-directory-p name)
           (not (equal f ".."))
           (not (equal f ".")))
      (unless (member base load-path)
        (add-to-list 'load-path name)))))))

(update-to-load-path (expand-file-name "elisp" user-emacs-directory))

(load-file "~/.emacs.d/custom.el")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(setq backup-directory-alist
  `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
  `((".*" ,temporary-file-directory t)))

(setq package-archives
  '(("melpa" . "https://melpa.org/packages/")
    ("elpa" . "https://elpa.gnu.org/packages/")
    ("nongnu" . "https://elpa.nongnu.org/nongnu/")
    ("melpa-stable" . "https://stable.melpa.org/packages/")))

(package-initialize)

;; ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq
 use-package-always-ensure t
 use-package-verbose t)

(use-package auto-package-update
  :if (not (daemonp))
  :custom
  (auto-package-update-interval 7) ;; in days
  (auto-package-update-prompt-before-update t)
  (auto-package-update-delete-old-versions t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe))

(use-package diminish
  :diminish visual-line-mode
  :diminish centered-window-mode
  :diminish eldoc-mode
  :diminish evil-collection-unimpaired-mode
  :diminish org-indent-mode
  :diminish lsp-lens-mode
  :diminish lsp-modeline-workspace-status-mode)

(setq user-full-name "Martin Lönn Andersson")
(setq user-mail-address "mlonna@pm.me")

(use-package exec-path-from-shell
  :config
  ;; which environment variables to import
  (dolist (var '("LANG" "LC_ALL"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package swiper :diminish)

(use-package markdown-mode :defer t)

(use-package flyspell
  :diminish flyspell-mode
  :hook
  ((markdown-mode org-mode text-mode) . flyspell-mode)
  (prog-mode . flyspell-prog-mode)
  :bind
  ("C-l" . flyspell-auto-correct-previous-word)
  :config
  (with-eval-after-load "ispell"
    (setenv "LANG" "en_US.UTF-8")
    (setq ispell-program-name "hunspell"
          ispell-dictionary "en_US,sv")

    ;; ispell-set-spellchecker-params has to be called before ispell-hunspell-add-multi-dic
    (ispell-set-spellchecker-params)
    (ispell-hunspell-add-multi-dic "en_US,sv")
    (setq ispell-personal-dictionary "~/.hunspell_personal")))

;; save text entered in minibuffer prompts
(setq history-length 25)
(savehist-mode 1)

;; save cursor position in files
(save-place-mode 1)

;; remember recently edited files
(recentf-mode 1)

;; auto reload non-file buffers
(setq global-auto-revert-non-file-buffers t)

(use-package undo-tree
  :defer t
  :diminish undo-tree-mode
  :init (global-undo-tree-mode)
  :custom
  (undo-tree-visualizer-diff t)
  (undo-tree-history-directory-alist `(("." . ,(expand-file-name ".backup" user-emacs-directory))))
  (undo-tree-visualizer-timestamps t))

(use-package general
  :config
  ;; leader key for hydras
  (general-create-definer my/leader-keys
    :keymaps '(normal visual emacs)
    :prefix ","
    :global-prefix ",")

  ;; make esc quit prompts
  (general-define-key
   "<escape>" 'keyboard-escape-quit)

  (general-define-key
   "C-=" #'text-scale-increase
   "C-+" #'text-scale-increase
   "C--" #'text-scale-decrease))

(use-package evil
  :diminish
  :demand t
  :bind
  ("C-z" . evil-local-mode)

  (:map evil-normal-state-map
        ("C-w h" . evil-window-left)
        ("C-w j" . evil-window-down)
        ("C-w k" . evil-window-up)
        ("C-w l" . evil-window-right))

  :hook
  (evil-mode . my/evil-hook)

  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-search-module 'evil-search)

  :config
  (defun my/evil-hook () ; modes to disable evil in
    (dolist (mode '(custom-mode
                    eshell-mode
                    git-rebase-mode
                    erc-mode
                    term-mode
                    ansi-term-mode))
      (add-to-list 'evil-emacs-state-modes mode)))

  (evil-mode +1)

  ;; move on visual lines unless a count is involved
  (with-eval-after-load 'evil
    (evil-define-motion evil-next-line (count)
      "Move the cursor COUNT screen lines down."
      :type line
      (let ((line-move-visual (unless count t)))
        (evil-line-move (or count 1))))

    (evil-define-motion evil-previous-line (count)
      "Move the cursor COUNT lines up."
      :type line
      (let ((line-move-visual (unless count t)))
        (evil-line-move (- (or count 1))))))

  :custom
  (evil-undo-system 'undo-tree)

  ;; horizontal movement crosses lines
  (evil-cross-lines t))

;; more vim keybindings (in non-file buffers)
(use-package evil-collection
  :after evil
  :diminish evil-collection-unimpaired-mode
  :config
  (evil-collection-init))

;; even even more vim keybindings (adds surround functionality)
(use-package evil-surround
  :config
  (global-evil-surround-mode +1))

(use-package hydra
  :config
  (my/leader-keys
    "t" '(hydra-theme/body :which-key "choose theme")
    "r" '(hydra-window/body :which-key "resize window")
    "s" '(hydra-text-scale/body :which-key "scale text")))

(defhydra hydra-theme (:timeout 4)
  "choose theme"
  ("l" (my/enable-theme 'standard-light) "standard-light")
  ("v" (my/enable-theme 'modus-vivendi) "modus-vivendi")
  ("t" (my/enable-theme 'doom-tokyo-night) "tokyo night")
  ("f" nil "finished" :exit t))

(defun my/disable-all-themes ()
  "Disable all active themes."
  (dolist (theme custom-enabled-themes)
    (disable-theme theme)))

(defun my/enable-theme (theme)
  "Enable the specified THEME and disable all other themes."
  (my/disable-all-themes)
  (load-theme theme t)
  (customize-save-variable 'my-chosen-theme theme))

(add-hook 'after-init-hook
          (lambda ()
            (if (boundp 'my-chosen-theme)
                (my/enable-theme my-chosen-theme)
              (my/enable-theme 'modus-vivendi))))

(defhydra hydra-window (:timeout 4)
  "resize window"
  ("h" (window-width-decrease) "decrease width")
  ("j" (window-height-increase) "increase height")
  ("k" (window-height-decrease) "decrease height")
  ("l" (window-width-increase) "increase width")
  ("f" nil "finished" :exit t))

;; resizes the window width based on the input
(defun resize-window-width (w)
  "Resizes the window width based on W."
  (interactive (list (if (> (count-windows) 1)
                         (read-number "Set the current window width in [1~9]x10%: ")
                       (error "You need more than 1 window to execute this function!"))))
  (message "%s" w)
  (window-resize nil (- (truncate (* (/ w 10.0) (frame-width))) (window-total-width)) t))

;; resizes the window height based on the input
(defun resize-window-height (h)
  "Resizes the window height based on H."
  (interactive (list (if (> (count-windows) 1)
                         (read-number "Set the current window height in [1~9]x10%: ")
                       (error "You need more than 1 window to execute this function!"))))
  (message "%s" h)
  (window-resize nil (- (truncate (* (/ h 10.0) (frame-height))) (window-total-height)) nil))

(defun resize-window (width delta)
  "Resize the current window's size.  If WIDTH is non-nil, resize width by some DELTA."
  (if (> (count-windows) 1)
      (window-resize nil delta width)
    (error "You need more than 1 window to execute this function!")))

;; shorcuts for window resize width and height
(defun window-width-increase ()
  (interactive)
  (resize-window t 5))

(defun window-width-decrease ()
  (interactive)
  (resize-window t -5))

(defun window-height-increase ()
  (interactive)
  (resize-window nil 5))

(defun window-height-decrease ()
  (interactive)
  (resize-window nil -5))

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :hook (dired-mode . (lambda () (dired-hide-details-mode)))
  :bind ("C-x C-j" . dired-jump)
  :custom
  (dired-free-space nil)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file)
  (use-package nerd-icons-dired ; use nerd icons in dired
  :diminish
  :hook
  (dired-mode . nerd-icons-dired-mode)))

;; helpful ui additions
(use-package counsel
  :diminish
  :bind
  ("M-x" . counsel-M-x)
  ("C-M-j" . counsel-switch-buffer)
  ("C-x C-f" . counsel-find-file)

  :config
  (counsel-mode +1))

(use-package ivy
  :diminish
  :bind
  ("C-s" . swiper)
  (:map ivy-switch-buffer-map
        ("C-d" . ivy-switch-buffer-kill))
  (:map ivy-reverse-i-search-map
        ("C-d" . ivy-reverse-i-search-kill))

  :config
  (ivy-mode 1)
  ;; hide "^" from ivy minibuffer
  (setq ivy-initial-inputs-alist nil))

;; helpful information for functions in minibuffers
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; command history for ivy
(use-package prescient)

;; ivy integration for prescient
(use-package ivy-prescient
  :init
  (ivy-prescient-mode 1))

;; more detailed help pages
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; display help for next command keystroke
(use-package which-key
  :diminish
  :config
  (which-key-mode 1))

(use-package vterm
  :commands vterm
  :bind ("C-x t" . vterm)
  :custom
  (term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (vterm-shell "zsh")
  (vterm-max-scrollback 10000))

(setq scroll-step 1
      scroll-margin 1
      scroll-conservatively 101
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      auto-window-vscroll nil
      fast-but-imprecise-scrolling nil
      mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      hscroll-step 1
      hscroll-margin 1)

(use-package perspective
  :hook (persp-created . dashboard-open)
  :bind
  ("C-x C-b" . persp-list-buffers)
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init
  (persp-mode))

(add-to-list 'default-frame-alist '(font . "Ubuntu Mono-17"))

(use-package nerd-icons)

(use-package mood-line
  :config
  ;(mood-line-mode 1)
  (column-number-mode t)) ; show column no. in modeline

(use-package standard-themes)

(use-package doom-themes)

(use-package spaceway-theme
  :ensure nil
  :load-path "elisp/spaceway/")

;; disable border around modelines
(custom-set-faces
 '(mode-line ((t (:box nil))))
 '(mode-line-inactive ((t (:box nil)))))

(use-package popper
  :bind
  ("C-å"   . popper-toggle)
  ("M-å"   . popper-cycle)
  ("C-M-å" . popper-toggle-type)
  :init
  (setq popper-reference-buffers
    '("\\*Messages\\*"
      "\\*Warnings\\*"
      "\\*Compile-Log\\*"
      "^\\*compilation.*\\*$" comint-mode
      "Output\\*$"
      help-mode
      helpful-mode
      compilation-mode
      "\\*Async Shell Command\\*"
      "^\\*eshell.*\\*$" eshell-mode
      "^\\*shell.*\\*$"  shell-mode
      "^\\*term.*\\*$"   term-mode
      "^\\*vterm.*\\*$"  vterm-mode
      "^\\*ansi-term.*\\*$"  ansi-term-mode
      "^\\*tex-shell.*\\*$"
      "^\\*Flycheck.*\\*$"))
  (popper-mode 1)
  (popper-echo-mode 1)
  (setq popper-mode-line " POP "))

;; turn on line numbers and highlight current line
(dolist (hook '(conf-mode-hook prog-mode-hook text-mode-hook markdown-mode-hook org-mode-hook))
  (add-hook hook 'display-line-numbers-mode)
  ;(add-hook hook 'hl-line-mode)
  )

;; relative line numbers
(setq display-line-numbers-type 'relative)

(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(use-package dashboard
  :demand t
  :diminish (dashboard-mode page-break-lines-mode)
  :custom-face
  (dashboard-items-face ((t (:weight normal))))
  :custom
  (dashboard-items '((bookmarks . 7)
                     (projects . 5)))
  :config
  (dashboard-setup-startup-hook)

  (setq dashboard-center-content t
        dashboard-set-footer nil
        dashboard-display-icons-p t
        dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name))

;; hook dashboard-open to creation of new frame
(add-hook 'after-make-frame-functions
        (lambda (frame)
          (with-selected-frame frame
            (dashboard-open))))

(use-package darkroom
  :bind ("C-x f" . darkroom-tentative-mode)
  :custom
  (darkroom-text-scale-increase 0.2))

(use-package perfect-margin
  :diminish
  :custom
  (perfect-margin-visible-width 100)
  :config
  (perfect-margin-mode t)
  (setq perfect-margin-ignore-modes
        '(dired-mode)))

(use-package prog-mode
  :ensure nil
  :mode ("\\.edn\\'" "\\.lua\\'"))

(use-package lsp-mode
  :commands lsp
  :diminish lsp-lens-mode
  :hook
  ((java-mode tex-mode) . lsp-deferred)

  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-auto-guess-root nil)
  (lsp-prefer-flymake nil) ; use flycheck instead of flymake
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (read-process-output-max (* 1024 1024))
  (lsp-keep-workspace-alive nil)
  (lsp-enable-which-key-integration t)

  ;; headerline breadcrumb
  (lsp-headerline-breadcrumb-segments '(path-up-to-project file))
  (lsp-headerline-breadcrumb-mode)

  :bind
  (:map lsp-mode-map ("C-c C-f" . lsp-format-buffer))

  :config
  (setq lsp-headerline-breadcrumb-icons-enable nil
        lsp-modeline-code-actions-enable nil
        lsp-signature-auto-activate t
        lsp-signature-render-documentation t
        lsp-modeline-diagnostics-enable nil
        lsp-eldoc-enable-hover t)

  (defun lsp-update-server ()
    "Update LSP server."
    (interactive)
    ;; equals to `C-u M-x lsp-install-server'
    (lsp-install-server t))

  ;; ivy integration
  (use-package lsp-ivy
    :after lsp)

  ;; treemacs integration
  (use-package lsp-treemacs
    :after lsp))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :after lsp-mode
  :diminish
  :commands lsp-ui-mode
  :custom-face
  (lsp-ui-doc-background ((t (:background nil))))
  (lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
  :bind
  (:map lsp-ui-mode-map
        ("M-r" . lsp-ui-peek-find-definitions)
        ("M-?" . lsp-ui-peek-find-references)
        ("C-c u" . lsp-ui-imenu)
        ("M-i" . lsp-ui-doc-glance))
  :custom
  (lsp-ui-doc-header t)
  (lsp-ui-doc-include-signature t)
  (lsp-ui-doc-border (face-foreground 'default))
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-ignore-duplicate t)
  (lsp-ui-sideline-show-code-actions nil)
  :config
  ;; use lsp-ui-doc-webkit only in GUI
  (when (display-graphic-p)
    (setq lsp-ui-doc-use-webkit t)))

(use-package dap-mode
  :diminish
  :bind
  (:map dap-mode-map
        (("<f12>" . dap-debug)
         ("<f8>" . dap-continue)
         ("<f9>" . dap-next)
         ("<M-f11>" . dap-step-in)
         ("C-M-<f11>" . dap-step-out)
         ("<f7>" . dap-breakpoint-toggle))))

(use-package flycheck
  :defer t
  :diminish
  :hook (lsp-mode . flycheck-mode)
  :commands (flycheck-add-mode)
  :bind ("C-c f e" . flycheck-list-errors)
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-indication-mode (if (display-graphic-p) 'left-fringe))
  :init
  (if (display-graphic-p)
      (use-package flycheck-posframe
        :custom-face
        (flycheck-posframe-face ((t (:foreground ,(face-foreground 'success)))))
        (flycheck-posframe-info-face ((t (:foreground ,(face-foreground 'success)))))
        :hook (flycheck-mode . flycheck-posframe-mode)
        :custom
        (flycheck-posframe-position 'window-bottom-left-corner)
        (flycheck-posframe-border-width 3)
        (flycheck-posframe-inhibit-functions
         '((lambda (&rest _) (bound-and-true-p company-backend)))))
    (use-package flycheck-pos-tip
      :defines flycheck-pos-tip-timeout
      :hook (flycheck-mode . flycheck-pos-tip-mode)
      :custom (flycheck-pos-tip-timeout 30)))
  :config
  (use-package flycheck-popup-tip
    :hook (flycheck-mode . flycheck-popup-tip-mode))

  (when (fboundp 'define-fringe-bitmap)
    (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
      [16 48 112 240 112 48 16] nil nil 'center)))

(use-package company
  :diminish
  :after lsp-mode
  :hook ((prog-mode LaTeX-mode latex-mode) . company-mode)
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :diminish
  :hook (company-mode . company-box-mode))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . (lambda () (rainbow-delimiters-mode))))

(use-package projectile
  :diminish
  :custom (projectile-completion-system 'ivy)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (setq projectile-switch-project-action #'projectile-find-file)
  :config
  (projectile-mode 1)
  (setq projectile-ignored-projects '("~/.cfg" "~/.emacs.d" "~/Projects/pathfinder")
        projectile-track-known-projects-automatically nil)

  (use-package counsel-projectile
    :config (counsel-projectile-mode 1)))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package lsp-java
  :after lsp-mode
  :if (executable-find "mvn")
  :init
  (use-package request :defer t)
  :custom
  (lsp-java-server-install-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/server/"))
  (lsp-java-workspace-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/workspace/")))

(use-package python-mode
  :ensure nil
  :after flycheck
  :mode "\\.py\\'"
  :custom
  (python-indent-offset 4)
  (flycheck-python-pycompile-executable "python3")
  (python-shell-interpreter "python3"))

(use-package tex
  :ensure auctex
  :defer t
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  ;; to use pdfview with auctex
  (TeX-view-program-selection '((output-pdf "pdf-tools"))
                             TeX-source-correlate-start-server t)
  (TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view")))
  (TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
  :hook
  (LaTeX-mode . (lambda ()
                  (turn-on-reftex)
                  (reftex-isearch-minor-mode)
                  (setq reftex-plug-into-AUCTeX t
                        TeX-PDF-mode t
                        TeX-source-correlate-method 'synctex
                        TeX-source-correlate-start-server t))))

(use-package org
  :pin nongnu
  :ensure org-contrib ; needed for org-contacts
  :diminish org-indent-mode
  :hook (org-mode . org-indent-mode)
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :config
  (setq org-directory "~/Documents/notes/org"
        org-default-notes-file (concat org-directory "/capture.org")
        org-todo-keywords '((sequence "TODO" "NEXT" "|" "DONE"))
        org-tags-column 0
        org-startup-folded t
        org-export-backends '(md org ascii html icalendar latex odt rss)
        org-ellipsis " ▾")

  ;; remap org indentation keys
  (with-eval-after-load 'org
    (general-define-key
     :keymaps 'org-mode-map
     "C-c i" 'org-metaright
     "C-c u" 'org-metaleft)))

;; change default bullets
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(use-package org-agenda
  :ensure nil
  :after org
  :config
  (setq org-agenda-span 'day
        org-agenda-tags-column 0
        org-agenda-start-on-weekday nil
        org-agenda-skip-scheduled-if-deadline-is-shown t
        org-agenda-skip-deadline-if-done t
        org-agenda-skip-scheduled-if-done t
        org-agenda-todo-list-sublevels t
        ;; org element cache often produced errors, so I disabled it
        org-element-use-cache nil
        org-agenda-scheduled-leaders '("" "")  ; hide "Scheduled" text
        org-agenda-prefix-format "  %?-12t% s" ; hide category for agenda items

        ;; add newline above date heading
        org-agenda-format-date
        (lambda (date)
          (concat "\n" (org-agenda-format-date-aligned date)))

        ;; time grid settings
        org-agenda-time-grid
        '((daily today require-timed remove-match)
          (800 1000 1200 1400 1600 1800 2000)
          "...." "------------")
        org-agenda-current-time-string
        "← now")

  ;; date heading settings
  (custom-set-faces
   '(org-agenda-date ((t (:height 1.0 :weight bold :background nil))))
   '(org-agenda-date-today ((t (:height 1.3 :weight bold :background nil :underline nil))))))

(use-package org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode 1)

  ;; only apply super agenda groups on org-agenda-list
  (defun my-org-agenda-list (orig-fun &rest args)
    (let ((org-super-agenda-groups
           '((:name "Schedule"
                    :time-grid t)
             (:name "Vanor"
                    :habit t)
             (:name "Overdue"
                    :deadline past
                    :scheduled past)
             (:name "Studier"
                    :and (:category "studier" :scheduled today)
                    :and (:category "studier" :deadline today))
             (:name "Privat"
                    :and (:category ("privat" "capture" "computer") :scheduled today)
                    :and (:category ("privat" "capture" "computer") :deadline today))
             (:name "Upcoming Deadlines"
                    :deadline future)
             (:discard (:anything t)))))
      (apply orig-fun args)))


  (advice-add 'org-agenda-list :around #'my-org-agenda-list))

(use-package org-capture
  :ensure nil
  :after org
  :config
  ;; don't save org capture bookmarks
  (setq org-bookmark-names-plist nil
        org-capture-bookmark nil)
  :custom
  (org-capture-templates
   '(
     ("t" "Task" entry (file "")
      "* TODO %?\n  %i\n")

     ("l" "Task with link" entry (file "")
      "* TODO %?\n  %i\n %a")

     ("n" "Note" entry (file "")
      "* %?\n %i\n")

     ("e" "Calendar event" entry (file "calendar.org")
      "* %?\n %^t")

     ("b" "Book" entry (file+headline "backlog.org" "Books")
      "* %?\n %i\n")

     ("m" "Movie" entry (file+headline "backlog.org" "Movies")
      "* %?\n %i\n")

     ("w" "Web" entry (file+headline "backlog.org" "Web")
      "* %i\n%U\n\n")

     ("c" "Contact" entry (file "")
      "* %?
        :PROPERTIES:
        :PHONE: %^{phone number}
        :ADDRESS: %^{Street name Street no., Postal Code Postal Area, Country}
        :BIRTHDAY: %^{yyyy-mm-dd}
        :EMAIL: %^{name@domain.com}
        :NOTE: %^{NOTE}
        :END:"))))

(use-package org-habit
  :ensure nil
  :after org
  :config
  (setq org-habit-show-habits-only-for-today t)

  ;; the org habit graph changes colors per theme,
  ;; so I define consistent colors for the habit graph
  (custom-set-faces
   '(org-habit-clear-face ((t (:background "#1468de"))))
   '(org-habit-clear-future-face ((t (:background "#1468de"))))
   '(org-habit-ready-face ((t (:background "#14de4a"))))
   '(org-habit-ready-future-face ((t (:background "#14de4a"))))
   '(org-habit-alert-face ((t (:background "#f0f00c"))))
   '(org-habit-alert-future-face ((t (:background "#f0f00c"))))
   '(org-habit-overdue-face ((t (:background "#f00c0c"))))
   '(org-habit-overdue-future-face ((t (:background "#f00c0c"))))))

(use-package org-contacts
  :after org
  :custom (org-contacts-files '("~/Documents/notes/org/contacts.org")))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (java . t)))

(setq org-confirm-babel-evaluate nil)
(org-babel-tangle-file "~/.emacs.d/init.org")

;; block templates
(setq org-structure-template-alist
      '(("l" . "src emacs-lisp")
        ("j" . "src java")
        ("s" . "src")
        ("e" . "example")
        ("q" . "quote")))

(use-package calfw
  :config
  ;; use swedish calendar
  (load "sv-kalender"))

;; integrate calfw with org
(use-package calfw-org
  :after calfw)

;; open calendar with two weeks view
(defun my/custom-open-calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "medium purple"))
   :view 'two-weeks))

(my/leader-keys
  "c" '(my/custom-open-calendar :which-key "open calendar"))

(use-package plantuml-mode
  :defer t
  :custom
  (org-plantuml-jar-path (expand-file-name "~/tools/plantuml/plantuml.jar")))

(use-package mu4e
  :ensure nil
  :defer 20 ; load 20 s after startup
  :commands (mu4e make-mu4e-context)
  :bind
  (:map mu4e-view-mode-map
    ("e" . mu4e-view-save-attachment))
  :config
  (add-to-list 'gnutls-trustfiles (expand-file-name "~/.config/protonmail/bridge/cert.pem"))

  (setq mail-user-agent 'mu4e-user-agent) ; mu4e default email client
  (set-variable 'read-mail-command 'mu4e) ; mu4e default email reader

  (setq
   ;; User info
   user-mail-address "mlonna@pm.me"
   user-full-name  "Martin Lönn Andersson"

   ;; Maildir setup
   mu4e-root-maildir "~/.mail"
   mu4e-attachment-dir "~/Downloads"
   mu4e-maildir-shortcuts
   '((:maildir "/INBOX"           :key ?i)
     (:maildir "/Folders/viktigt" :key ?v)
     (:maildir "/Folders/orders"  :key ?b))

   mu4e-contexts
   `(,(make-mu4e-context
       :name "prof"
       :match-func
       (lambda (msg)
         (when msg
           (mu4e-message-contact-field-matches msg
                                               :to "mlonna@pm.me")))
       :vars '((user-mail-address . "mlonna@pm.me" )
               (user-full-name . "Martin Lönn Andersson")
               (mu4e-drafts-folder . "/Drafts")
               (mu4e-sent-folder . "/Sent")
               (mu4e-refile-folder . "/Archive")
               (mu4e-trash-folder . "/Trash")))

     ,(make-mu4e-context
       :name "me"
       :match-func
       (lambda (msg)
         (when msg
           (mu4e-message-contact-field-matches msg
                                               :to "nitramla@pm.me")))
       :vars '((user-mail-address . "nitramla@pm.me")
               (user-full-name . "Martin")
               (mu4e-drafts-folder . "/Drafts")
               (mu4e-sent-folder . "/Sent")
               (mu4e-refile-folder . "/Archive")
               (mu4e-trash-folder . "/Trash")))

     ,(make-mu4e-context
       :name "safe"
       :match-func
       (lambda (msg)
         (when msg
           (mu4e-message-contact-field-matches msg
                                               :to "hemlg@pm.me")))
       :vars '((user-mail-address . "hemlg@pm.me")
               (user-full-name . "Martin")
               (mu4e-drafts-folder . "/Drafts")
               (mu4e-sent-folder . "/Sent")
               (mu4e-refile-folder . "/Archive")
               (mu4e-trash-folder . "/Trash")))

     ,(make-mu4e-context
       :name "trash"
       :match-func
       (lambda (msg)
         (when msg
           (mu4e-message-contact-field-matches msg
                                               :to "trshcan@pm.me")))
       :vars '((user-mail-address . "trshcan@pm.me")
               (user-full-name . "Martin")
               (mu4e-drafts-folder . "/Drafts")
               (mu4e-sent-folder . "/Sent")
               (mu4e-refile-folder . "/Archive")
               (mu4e-trash-folder . "/Trash"))))

   ;; start with the first (default) context
   mu4e-context-policy 'pick-first
   ;; ask for context if no context matches
   mu4e-compose-context-policy 'ask

   ;; Fetch mail
   mu4e-get-mail-command "mbsync -a"
   mu4e-change-filenames-when-moving t   ; needed for mbsync
   mu4e-update-interval 120              ; update every 2 minutes

   ;; Send mail
   message-send-mail-function 'message-send-mail-with-sendmail
   smtpmail-auth-credentials "~/.authinfo"
   smtpmail-smtp-server "127.0.0.1"
   smtpmail-smtp-service 1025
   smtpmail-stream-type 'starttls

   ;; Other options
   mu4e-confirm-quit nil
   ;; re-flow mail so it's not hard wrapped
   mu4e-compose-format-flowed t
   ;; hide annoying retrieving msg in mini buffer
   mu4e-hide-index-messages t
   mu4e-index-update-error-warning 'nil))

(my/leader-keys
  "m" '(mu4e :which-key "open mail"))

(use-package pdf-tools
  :mode "\\.pdf\\'"
  :custom
  (TeX-view-program-selection '((output-pdf "pdf-tools")))
  (TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view")))
  :config
  (pdf-tools-install))

;; display right and left fringe
(fringe-mode '(8 . 8))

;; soft-wrap text
(global-visual-line-mode t)

;; tabs are four spaces
(setq-default tab-width 4
              indent-tabs-mode nil)

;; set language environment
(set-language-environment "UTF-8")

;; clean up unneccesary whitespace on save
(add-hook 'before-save-hook 'whitespace-cleanup)

;; map yes and no to y and n
(fset 'yes-or-no-p 'y-or-n-p)

;; disable visual and audible bell
(setq ring-bell-function 'ignore)

;; increase large file warning threshold
(setq large-file-warning-threshold 100000000)

;; automatically reload files when changed
(global-auto-revert-mode t)

;; suppress auto revert messages
(setq auto-revert-verbose nil)

;; automatically kill all active processes when closing Emacs
(setq confirm-kill-processes nil)

;; add a newline automatically at the end of the file upon save
(setq require-final-newline t)
