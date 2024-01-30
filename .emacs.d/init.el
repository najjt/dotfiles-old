(setq package-enable-at-startup nil)

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(defvar better-gc-cons-threshold 419430400; 512mb
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
  (setq dired-use-ls-dired nil))

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
    ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

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
  :diminish abbrev-mode
  :diminish lsp-lens-mode)

(setq user-full-name "Martin Lönn Andersson")
(setq user-mail-address "mlonna@pm.me")

(use-package exec-path-from-shell
  :config
  ;; which environment variables to import
  (dolist (var '("LANG" "LC_ALL"))
    (add-to-list 'exec-path-from-shell-variables var))

  ;; activate exec-path-from-shell on macos and linux
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))

  ;; activate exec-path-from-shell when emacs is launched as daemon
  (when (daemonp)
    (exec-path-from-shell-initialize)))

(use-package swiper
  :diminish
  :config
  (define-key swiper-map (kbd "C-h") 'delete-backward-char))

(use-package markdown-mode)

(use-package flyspell
  :diminish flyspell-mode
  :hook
  ((markdown-mode org-mode text-mode) . flyspell-mode)
  (prog-mode . flyspell-prog-mode)

  :config
  (general-define-key
   "C-l" 'flyspell-auto-correct-previous-word)

  (with-eval-after-load "ispell"
    (setenv "LANG" "en_US.UTF-8")
    (setq ispell-program-name "hunspell")
    (setq ispell-dictionary "en_US,sv")

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
  :bind (
     ("C-z" . evil-local-mode)

     :map evil-normal-state-map
     ("C-w h" . evil-window-left)
     ("C-w j" . evil-window-down)
     ("C-w k" . evil-window-up)
     ("C-w l" . evil-window-right)

     :map evil-insert-state-map
     ("C-h" . evil-delete-backward-char-and-join))

  :hook
  (evil-mode . my/evil-hook)
  (doc-view-mode . turn-off-evil-mode)

  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-search-module 'evil-search)

  :config
  (defun my/evil-hook () ; modes to disable evil in
    (dolist (mode '(custom-mode
            eshell-mode
            git-rebase-mode
            erc-mode
            term-mode
            ansi-term-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)

  ;; horizontal movement crosses lines
  (setq-default evil-cross-lines t)

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
    (evil-line-move (- (or count 1)))))))

;; more vim keybindings (in non-file buffers)
(use-package evil-collection
  :after evil
  :diminish
  :config
  (evil-collection-init))

;; even even more vim keybindings (adds surround functionality)
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package hydra
  :config
  (my/leader-keys
    "t" '(hydra-theme/body :which-key "choose theme")
    "r" '(hydra-window/body :which-key "resize window")
    "s" '(hydra-text-scale/body :which-key "scale text")))

(defhydra hydra-theme (:timeout 4)
  "choose theme"
  ("d" (my/enable-theme 'doom-one) "doom one")
  ("s" (my/enable-theme 'spaceway) "spaceway")
  ("o" (my/enable-theme 'modus-operandi) "modus-operandi")
  ("v" (my/enable-theme 'modus-vivendi) "modus-vivendi")
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
  :config
  (setq dired-free-space nil)

  (use-package dired-single) ; reuse buffer
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer)

  (use-package nerd-icons-dired ; use nerd icons in dired
  :diminish
  :hook
  (dired-mode . nerd-icons-dired-mode)))

;; helpful ui additions
(use-package counsel
  :diminish
  :bind (("M-x" . counsel-M-x)
     ("C-M-j" . counsel-switch-buffer)
     ("C-x C-f" . counsel-find-file))

  :config
  (counsel-mode 1)
  (define-key ivy-minibuffer-map (kbd "C-h") 'delete-backward-char))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
     :map ivy-minibuffer-map
     ("TAB" . ivy-alt-done)
     ("C-l" . ivy-alt-done)
     :map ivy-switch-buffer-map
     ("C-l" . ivy-done)
     ("C-d" . ivy-switch-buffer-kill)
     :map ivy-reverse-i-search-map
     ("C-d" . ivy-reverse-i-search-kill))

  :config
  (ivy-mode 1)
  (setq ivy-initial-inputs-alist nil) ; hide "^" from ivy minibuffer
  (define-key ivy-minibuffer-map (kbd "C-h") 'delete-backward-char))

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

(use-package discover-my-major
  :bind ("C-h C-m" . discover-my-major))

(use-package vterm
  :commands vterm
  :bind ("C-x t" . vterm)
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-shell "zsh")
  (setq vterm-max-scrollback 10000))

(setq scroll-step 1)
(setq scroll-margin 1)
(setq scroll-conservatively 101)
(setq scroll-up-aggressively 0.01)
(setq scroll-down-aggressively 0.01)
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
;; Horizontal Scroll
(setq hscroll-step 1)
(setq hscroll-margin 1)

(add-to-list 'default-frame-alist '(font . "Ubuntu Mono-17"))

;; nerd icons
(use-package nerd-icons)

(use-package mood-line
  :config
  (mood-line-mode 1)
  (column-number-mode t)) ; show column no. in modeline

(use-package doom-themes)

(use-package spaceway-theme
  :ensure nil
  :load-path "elisp/spaceway/")

;; disable border around modelines
(custom-set-faces
 '(mode-line ((t (:box nil))))
 '(mode-line-inactive ((t (:box nil)))))

(use-package popper
  :bind (("C-å"   . popper-toggle)
     ("M-å"   . popper-cycle)
     ("C-M-å" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
    '("\\*Messages\\*"
      "\\*Warnings\\*"
      "\\*Compile-Log\\*"
      "Output\\*$"
      "\\*Async Shell Command\\*"
      help-mode
      compilation-mode
      "^\\*compilation.*\\*$" comint-mode
      "^\\*eshell.*\\*$" eshell-mode
      "^\\*shell.*\\*$"  shell-mode
      "^\\*term.*\\*$"   term-mode
      "^\\*vterm.*\\*$"  vterm-mode
      "^\\*ansi-term.*\\*$"  ansi-term-mode)
    )
  (popper-mode +1)
  (popper-echo-mode +1)
  (setq popper-mode-line " POP ")
  )

;; turn on line numbers and highlight current line
(dolist (hook '(prog-mode-hook text-mode-hook markdown-mode-hook org-mode-hook))
  (add-hook hook 'display-line-numbers-mode)
  (add-hook hook 'hl-line-mode))

;; relative line numbers
(setq display-line-numbers-type 'relative)

(use-package dashboard
  :demand
  :diminish (dashboard-mode page-break-lines-mode)
  :custom
  (dashboard-items '((bookmarks . 7)))
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-set-footer nil)
  (setq dashboard-display-icons-p nil))

;; set dashboard buffer as initial buffer choice
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

;; hook dashboard-open to creation of new frame
(add-hook 'after-make-frame-functions
        (lambda (frame)
          (with-selected-frame frame
            (dashboard-open))))

(use-package prog-mode
  :ensure nil
  :mode "\\.edn\\'")

(use-package lsp-mode
  :commands lsp
  :hook (java-mode . lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-auto-guess-root nil)
  (lsp-prefer-flymake nil) ; use flycheck instead of flymake
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (read-process-output-max (* 1024 1024))
  (lsp-keep-workspace-alive nil)
  (lsp-eldoc-hook nil)
  (lsp-enable-which-key-integration t)

  ;; headerline breadcrumb
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file))
  (lsp-headerline-breadcrumb-mode)

  :bind (:map lsp-mode-map ("C-c C-f" . lsp-format-buffer))
  :config
  (defun lsp-update-server ()
    "Update LSP server."
    (interactive)
    ;; equals to `C-u M-x lsp-install-server'
    (lsp-install-server t))
  (setq lsp-headerline-breadcrumb-icons-enable nil)
  (setq lsp-modeline-code-action-fallback-icon "[A]"))

;; ivy integration
(use-package lsp-ivy)

;; treemacs integration
(use-package lsp-treemacs
  :after lsp)

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
        ("M-i" . lsp-ui-doc-focus-frame))
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
    (setq lsp-ui-doc-use-webkit t))
  ;; WORKAROUND Hide mode-line of the lsp-ui-imenu buffer
  ;; https://github.com/emacs-lsp/lsp-ui/issues/243
  (defadvice lsp-ui-imenu (after hide-lsp-ui-imenu-mode-line activate)
    (setq mode-line-format nil))
  ;; `C-g'to close doc
  (advice-add #'keyboard-quit :before #'lsp-ui-doc-hide))

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
  :hook (after-init . global-flycheck-mode)
  :commands (flycheck-add-mode)
  :bind ("C-c f e" . flycheck-list-errors)
  :custom
  (flycheck-global-modes
   '(not outline-mode diff-mode shell-mode eshell-mode term-mode))
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-indication-mode (if (display-graphic-p) 'right-fringe 'right-margin))
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
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
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
  :hook
  (prog-mode . (lambda () (rainbow-delimiters-mode))))

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
                (setq reftex-plug-into-AUCTeX t)
                (reftex-isearch-minor-mode)
                (setq TeX-PDF-mode t)
                (setq TeX-source-correlate-method 'synctex)
                (setq TeX-source-correlate-start-server t))))

(use-package org
  :pin nongnu
  :ensure org-contrib ; needed for org-contacts
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :config
  (setq org-directory "~/Documents/notes/org")
  (setq org-default-notes-file (concat org-directory "/capture.org"))
  (setq org-todo-keywords '((sequence "TODO" "NEXT" "|" "DONE")))
  (setq org-tags-column 0)
  (setq org-startup-folded t)
  (setq org-export-backends '(md org ascii html icalendar latex odt rss))

  ;; remap org indentation keys
  (with-eval-after-load 'org
    (general-define-key
     :keymaps 'org-mode-map
     "C-c i" 'org-metaright
     "C-c u" 'org-metaleft)))

(use-package org-agenda
  :ensure nil
  :after org
  :config
  (setq org-agenda-span 'day)
  (setq org-agenda-tags-column 0)
  (setq org-agenda-start-on-weekday nil)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-todo-list-sublevels t)
  (setq org-agenda-scheduled-leaders '("" ""))
  (setq org-element-use-cache nil) ; org element cache often produced errors, so I disabled it

  ;; date heading text settings
  (custom-set-faces
   '(org-agenda-date ((t (:height 1.0 :weight bold))))
   '(org-agenda-date-today ((t (:height 1.0 :weight bold)))))

  ;; time grid settings
  (setq org-agenda-time-grid
    '((daily today require-timed remove-match)
      (800 1000 1200 1400 1600 1800 2000)
      "...." "------------")
    org-agenda-current-time-string
    "← now"))

(use-package org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode t)
  (setq org-super-agenda-groups
        '((:name "Schedule"
                 :time-grid t)
          (:name "Vanor"
                 :habit t)
          (:name "Upcoming"
                 :deadline future)
          (:name "Studier"
                 :category "studier")
          (:name "Privat"
                 :category ("privat" "capture" "computer"))
          (:discard (:anything t))))
  (org-agenda-list))

(use-package org-capture
  :ensure nil
  :after org
  :config
  ;; don't save org capture bookmarks
  (setq org-bookmark-names-plist nil)
  (setq org-capture-bookmark nil)
  :custom
  (org-capture-templates
   '(
     ("t" "Task")

     ("tt" "Task" entry (file+headline "" "Tasks")
  "* TODO %?\n  %i\n")

     ("tl" "Task with link" entry (file+headline "" "Tasks")
  "* TODO %?\n  %i\n %a")

     ("n" "Note" entry (file+headline "" "Notes")
  "* %?\n %i\n")

     ("c" "Contact" entry (file+headline "" "Contacts")
  "* %?
        :PROPERTIES:
        :PHONE: %^{phone number}
        :ADDRESS: %^{Street name Street no., Postal Code Postal Area, Country}
        :BIRTHDAY: %^{yyyy-mm-dd}
        :EMAIL: %^{name@domain.com}
        :NOTE: %^{NOTE}
        :END:")

     ("e" "Calendar event" entry (file+headline "calendar.org" "Calendar")
  "* %?\n %^t")

     ("m" "Media")

     ("mb" "Book" entry (file+headline "backlog.org" "Books")
  "* %?\n %i\n")

     ("mm" "Movie" entry (file+headline "backlog.org" "Movies")
  "* %?\n %i\n")

     ("mw" "Web Capture" entry (file+headline "backlog.org" "Web")
  "* %i\n%U\n\n"))))

(when *sys/mac*
  (use-package org-mac-link)
  (use-package noflet))

(defun timu-func-url-qutebrowser-capture-to-org ()
  "Call `org-capture-string' on the current frontmost qutebrowser window.
Use `org-mac-link-qutebrowser-get-frontmost-url' to capture URL from qutebrowser.
Triggered by a custom macOS Quick Action with a keyboard shortcut."
  (interactive)
  (org-capture-string (org-mac-link-qutebrowser-get-frontmost-url) "mw")
  (ignore-errors)
  (org-capture-finalize))

(defun timu-func-make-capture-frame ()
  "Create a new frame and run `org-capture'."
  (interactive)
  (make-frame '((name . "capture")
                (top . 300)
                (left . 700)
                (width . 80)
                (height . 25)))
  (select-frame-by-name "capture")
  (delete-other-windows)
  (noflet ((switch-to-buffer-other-window (buf) (switch-to-buffer buf)))
    (org-capture)))

(defadvice org-capture-finalize
    (after delete-capture-frame activate)
  "Advise capture-finalize to close the frame."
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

(defadvice org-capture-destroy
    (after delete-capture-frame activate)
  "Advise capture-destroy to close the frame."
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

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
  (use-package calfw-org) ; integrate calfw with org

  (general-define-key
   "C-c o" 'cfw:open-org-calendar))

(load "sv-kalender")

(use-package plantuml-mode
  :defer t
  :custom
  (org-plantuml-jar-path (expand-file-name "~/tools/plantuml/plantuml.jar")))

(use-package mu4e
  :ensure nil
  :defer 20 ; load 20 s after startup
  :commands (mu4e make-mu4e-context)
  :bind
  (("C-x m" . mu4e)
   (:map mu4e-view-mode-map
     ("e" . mu4e-view-save-attachment)))
  :config
  (add-to-list 'gnutls-trustfiles (expand-file-name "~/.config/protonmail/bridge/cert.pem"))
  (setq
   ;; User info
   user-mail-address "mlonna@pm.me"
   user-full-name  "Martin Lönn Andersson"

   ;; Maildir setup
   mu4e-maildir "~/.mail"
   mu4e-attachment-dir "~/Downloads"

   ;; Fetch mail
   mu4e-get-mail-command "mbsync -a"
   mu4e-change-filenames-when-moving t   ; needed for mbsync
   mu4e-update-interval 120              ; update every 2 minutes

   ;; Send mail
   message-send-mail-function 'smtpmail-send-it
   smtpmail-auth-credentials "~/.authinfo"
   smtpmail-smtp-server "127.0.0.1"
   smtpmail-smtp-service 1025
   smtpmail-stream-type 'starttls

   ;; Other options
   mu4e-confirm-quit nil
   mu4e-compose-format-flowed t ; re-flow mail so it's not hard wrapped
   ))

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

;; automatically kill all active processes when closing Emacs
(setq confirm-kill-processes nil)

;; add a newline automatically at the end of the file upon save
(setq require-final-newline t)
