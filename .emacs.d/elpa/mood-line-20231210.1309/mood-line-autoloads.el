;;; mood-line-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from mood-line.el

(defvar mood-line-mode nil "\
Non-nil if Mood-Line mode is enabled.
See the `mood-line-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `mood-line-mode'.")
(custom-autoload 'mood-line-mode "mood-line" nil)
(autoload 'mood-line-mode "mood-line" "\
Toggle mood-line on or off.

This is a global minor mode.  If called interactively, toggle the
`Mood-Line mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='mood-line-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(register-definition-prefixes "mood-line" '("mood-line-"))


;;; Generated autoloads from mood-line-segment-checker.el

(register-definition-prefixes "mood-line-segment-checker" '("mood-line-segment-checker--f"))


;;; Generated autoloads from mood-line-segment-indentation.el

(register-definition-prefixes "mood-line-segment-indentation" '("mood-line-segment-indentation"))


;;; Generated autoloads from mood-line-segment-modal.el

(register-definition-prefixes "mood-line-segment-modal" '("mood-line-segment-modal-"))


;;; Generated autoloads from mood-line-segment-vc.el

(register-definition-prefixes "mood-line-segment-vc" '("mood-line-segment-vc--"))


;;; End of scraped data

(provide 'mood-line-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; mood-line-autoloads.el ends here
