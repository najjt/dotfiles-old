(setq gc-cons-threshold 100000000)

(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)
(set-fringe-mode 0)

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(undecorated-round . t))
  (setq frame-resize-pixelwise t))

(require 'server)
(if (not (server-running-p)) (server-start))
