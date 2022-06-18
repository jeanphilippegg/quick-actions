;;; quick-actions.el --- Quick actions menu -*- lexical-binding:t -*-

;; Copyright (C) 2022 Jean-Philippe Gagné Guay

;; Author: Jean-Philippe Gagné Guay <jeanphilippe150@gmail.com>

;; This file is part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a configurable menu of quick actions.

;;; Code:

;;;###autoload
(defcustom quick-action-alist nil
  "Alist of quick actions. The elements are (NAME . (FUNC ARGS)), where:

 NAME is the string that will appear as a candidate that can be selected
with `quick-action-select'

 FUNC is the symbol of a function and ARGS is a list of arguments passed to FUNC."
  :type '(alist :key-type string
		:value-type (list function sexp))
  :safe #'listp)

(defvar last-quick-action nil)
(make-variable-buffer-local 'last-quick-action)

(defvar quick-action-history nil)

;;;###autoload
(defun quick-action-select ()
  "Executes a quick action.

If `quick-action-alist' is nil (the default), this command is equivalent to `compile'.

If `quick-action-alist' contains a single item, do not prompt and execute this item directly.

Else, prompt for an ACTION among `quick-action-alist' keys and execute its associated function."
  (interactive)
  (cond ((not quick-action-alist)
	 (call-interactively #'compile))
	((equal (length quick-action-alist) 1)
	 (let* ((entry (car quick-action-alist))
		(quick-action (car entry))
		(func (cadr entry))
		(args (cddr entry)))
	   (setq last-quick-action quick-action)
	   (apply func args)))
	(t
	 (let* ((default (if (and last-quick-action
				  (assoc last-quick-action quick-action-alist))
			     last-quick-action
			   (caar quick-action-alist)))
		(prompt (format "Quick action (default %s): " default))
		(completion-ignore-case t)
		(quick-action (completing-read prompt (map-keys quick-action-alist)
					       nil t nil 'quick-action-history default))
		(entry (assoc quick-action quick-action-alist))
		(func (cadr entry))
		(args (cddr entry)))
	   (setq last-quick-action quick-action)
	   (apply func args)))))

(provide 'quick-actions)
