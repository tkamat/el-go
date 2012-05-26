;;; go-trans.el --- Translate and transfer between GO back ends

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

;;; Commentary:

;; An API for transferring GO moves and data between a number of GO
;; back ends including the following.
;; - the SGF format
;; - the Go Text Protocol (GTP)
;; - the IGS protocol

;;; Code:
(require 'go-util)
(require 'eieio)

(defgeneric go->move    (back-end move)    "Send MOVE to BACK-END.")
(defgeneric go->board   (back-end size)    "Send SIZE to BACK-END.")
(defgeneric go->resign  (back-end resign)  "Send RESIGN to BACK-END.")
(defgeneric go->undo    (back-end)         "Tell BACK-END undo the last move.")
(defgeneric go->comment (back-end comment) "Send COMMENT to BACK-END.")
(defgeneric go->reset   (back-end)         "Reset the current BACK-END.")
(defgeneric go<-size    (back-end)         "Get size from BACK-END")
(defgeneric go<-name    (back-end)         "Get a game name from BACK-END.")
(defgeneric go<-alt     (back-end)         "Get an alternative from BACK-END.")
(defgeneric go<-move    (back-end color)   "Get a pos from BACK-END.")
(defgeneric go<-turn    (back-end color)   "Get a full turn from BACK-END.")
(defgeneric go<-comment (back-end)         "Get COMMENT from BACK-END.")

(provide 'go-trans)