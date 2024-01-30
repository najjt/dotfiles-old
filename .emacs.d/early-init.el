(setq gc-cons-threshold 100000000)

(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)
(set-fringe-mode 0)

(require 'server)
(if (not (server-running-p)) (server-start))
