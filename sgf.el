;;; sgf.el --- SGF back end

;; Copyright (C) 2012 Eric Schulte <eric.schulte@gmx.com>

;; Author: Eric Schulte <eric.schulte@gmx.com>
;; Created: 2012-05-15
;; Version: 0.1
;; Keywords: game go sgf

;; This file is not (yet) part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; Commentary:

;; This file implements an `sgf-trans' interface into an SGF file.

;; Code:
(require 'sgf-util)
(require 'sgf-trans)

(defun sgf-nthcdr (sgf index)
  (let ((part sgf))
    (while (cdr index)
      (setq part (nth (car index) part))
      (setq index (cdr index)))
    (setq part (nthcdr (car index) part))
    part))

(defun sgf-ref (sgf index)
  (let ((part sgf))
    (while (car index)
      (setq part (nth (car index) part))
      (setq index (cdr index)))
    part))

(defun set-sgf-ref (sgf index new)
  (eval `(setf ,(reduce (lambda (acc el) (list 'nth el acc))
                        index :initial-value 'sgf)
               ',new)))

(defsetf sgf-ref set-sgf-ref)


;;; Class and interface
(defclass sgf nil
  ((sgf   :initarg :sgf   :accessor sgf   :initform nil)
   (index :initarg :index :accessor index :initform nil))
  "Class for the SGF back end.")

(defmethod sgf->move    ((sgf sgf) move))
(defmethod sgf->board   ((sgf sgf) size))
(defmethod sgf->resign  ((sgf sgf) resign))
(defmethod sgf->undo    ((sgf sgf) undo))
(defmethod sgf->comment ((sgf sgf) comment))
(defmethod sgf<-alt     ((sgf sgf)))
(defmethod sgf<-move    ((sgf sgf)))
(defmethod sgf<-board   ((sgf sgf)))
(defmethod sgf<-comment ((sgf sgf)))

(provide 'sgf)