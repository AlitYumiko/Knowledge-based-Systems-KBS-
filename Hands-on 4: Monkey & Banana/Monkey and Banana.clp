;; ------------------------------------------------------------------
;;  Template
;; ------------------------------------------------------------------
(deftemplate state
   (slot monkey-h (type SYMBOL)) ; Pos: atdoor, atwindow, middle
   (slot monkey-v (type SYMBOL)) ; Pos: onfloor, onbox
   (slot box-pos (type SYMBOL))  ; Pos: atdoor, atwindow, middle
   (slot has-banana (type SYMBOL) (default hasnot)) ; hasnot | has
)

;; ------------------------------------------------------------------
;;  Facts
;; ------------------------------------------------------------------
;; Call one of these BEFORE using (run).

;; Scenario 1: The original problem
(deffunction setup-scenario-1 ()
   (reset) ;Clear all previous facts
   (printout t "Loading Scenario 1: Monkey at door, box at window." crlf)
   (assert (state (monkey-h atdoor) (monkey-v onfloor) (box-pos atwindow) (has-banana hasnot)))
)

;; Scenario 2: Box is already in the middle
(deffunction setup-scenario-2 ()
   (reset)
   (printout t "Loading Scenario 2: Box is already in the middle." crlf)
   (assert (state (monkey-h atdoor) (monkey-v onfloor) (box-pos middle) (has-banana hasnot)))
)

;; Scenario 3: Monkey "stuck" on the box in the wrong location
(deffunction setup-scenario-3 ()
   (reset)
   (printout t "Loading Scenario 3: Monkey stuck on box (wrong location)." crlf)
   (assert (state (monkey-h atwindow) (monkey-v onbox) (box-pos atwindow) (has-banana hasnot)))
)

;; Scenario 4: Ready to climb
(deffunction setup-scenario-4 ()
   (reset)
   (printout t "Loading Scenario 4: Ready to climb (monkey and box in middle)." crlf)
   (assert (state (monkey-h middle) (monkey-v onfloor) (box-pos middle) (has-banana hasnot)))
)

;; Scenario 5: Ready to grasp
(deffunction setup-scenario-5 ()
   (reset)
   (printout t "Loading Scenario 5: Ready to grasp the banana." crlf)
   (assert (state (monkey-h middle) (monkey-v onbox) (box-pos middle) (has-banana hasnot)))
)

;; ------------------------------------------------------------------
;;  Rules
;; ------------------------------------------------------------------

;; --- Action: GRASP ---
(defrule grasp-banana
   ?s <- (state (monkey-h middle)
                (monkey-v onbox)
                (box-pos middle)
                (has-banana hasnot))
   =>
   (printout t "Action: Grasp the banana!" crlf)
   (retract ?s)
   (assert (state (monkey-h middle) (monkey-v onbox) (box-pos middle) (has-banana has)))
)

;; --- Action: CLIMB ---
(defrule climb-on-box-at-middle
   ?s <- (state (monkey-h middle)
                (monkey-v onfloor)
                (box-pos middle)
                (has-banana hasnot))
   =>
   (printout t "Action: Climb onto the box." crlf)
   (retract ?s)
   (assert (state (monkey-h middle) (monkey-v onbox) (box-pos middle) (has-banana hasnot)))
)

;; --- Action: PUSH ---
(defrule push-box-to-middle
   ?s <- (state (monkey-h ?P1)
                (monkey-v onfloor)
                (box-pos ?P1)
                (has-banana ?H))
   (test (not (eq ?P1 middle)))
   =>
   (printout t "Action: Push the box from " ?P1 " to middle." crlf)
   (retract ?s)
   (assert (state (monkey-h middle) (monkey-v onfloor) (box-pos middle) (has-banana ?H)))
)

;; --- Action: WALK ---
(defrule walk-to-box
   ?s <- (state (monkey-h ?P1)
                (monkey-v onfloor)
                (box-pos ?P2)
                (has-banana ?H))
   (test (not (eq ?P1 ?P2)))
   =>
   (printout t "Action: Walk from " ?P1 " to " ?P2 "." crlf)
   (retract ?s)
   (assert (state (monkey-h ?P2) (monkey-v onfloor) (box-pos ?P2) (has-banana ?H)))
)

;; --- Action: CLIMB DOWN ---
(defrule climb-down-from-box
   ?s <- (state (monkey-h ?P)
                (monkey-v onbox)
                (box-pos ?P)
                (has-banana ?H))
   (test (not (eq ?P middle)))
   =>
   (printout t "Action: Climb down from box at " ?P " (wrong location)." crlf)
   (retract ?s)
   (assert (state (monkey-h ?P) (monkey-v onfloor) (box-pos ?P) (has-banana ?H)))
)

;; ------------------------------------------------------------------
;;  Goal Rule
;; ------------------------------------------------------------------
(defrule goal-achieved
   (declare (salience 10))
   (state (has-banana has))
   =>
   (printout t "------------------------------------" crlf)
   (printout t "SUCCESS! The monkey has the banana." crlf)
   (halt)
)