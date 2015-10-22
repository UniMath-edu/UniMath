(* -*- coding: utf-8 -*- *)

Require Import UniMath.Foundations.FiniteSets.
Unset Automatic Introduction.
Require Import UniMath.Foundations.FunctionalExtensionality.
Local Open Scope poset.

(* propositions, move upstream *)

Lemma neg_isdecprop {X} : isdecprop X -> isdecprop (¬ X).
Proof.
  intros ? i.
  assert (j := isdecproptoisaprop X i).
  apply isdecpropif.
  { apply isapropneg. }
  unfold isdecprop in i.
  assert (k := pr1 i); clear i.
  induction k as [k|k].
  { apply ii2. now apply todneg. }
  now apply ii1.
Defined.

Definition decidableProposition := Σ X:UU, isdecprop X.

Definition decidableProposition_to_hProp : decidableProposition -> hProp.
Proof.
  intros X.
  exact (pr1 X,, isdecproptoisaprop (pr1 X) (pr2 X)).
Defined.
Coercion decidableProposition_to_hProp : decidableProposition >-> hProp.
Definition decidabilityProperty (X:decidableProposition) :
  isdecprop X := pr2 X.

Definition decidableSubtype (X:UU) := X -> decidableProposition.

Definition underlyingType {X} : decidableSubtype X -> UU.
Proof. intros ? S. exact (Σ x, S x). Defined.
Coercion underlyingType : decidableSubtype >-> UU.

Definition decidableRelation (X:UU) := X -> X -> decidableProposition.

Definition decrel_to_decidableProposition {X} : decrel X -> decidableRelation X.
Proof.
  intros ? R x y. induction R as [R is]. exists (R x y).
  apply isdecpropif. { apply propproperty. } apply is.
Defined.

Definition natlth_decidableProposition := decrel_to_decidableProposition natlthdec.
Definition natleh_decidableProposition := decrel_to_decidableProposition natlehdec.
Definition natgth_decidableProposition := decrel_to_decidableProposition natgthdec.
Definition natgeh_decidableProposition := decrel_to_decidableProposition natgehdec.
Definition nateq_decidableProposition := decrel_to_decidableProposition natdeceq.
Definition natneq_decidableProposition := decrel_to_decidableProposition natdecneq.

Notation " x <? y " := ( natlth_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x <=? y " := ( natleh_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x ≤? y " := ( natleh_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x >=? y " := ( natgeh_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x ≥? y " := ( natgeh_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x >? y " := ( natgth_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x =? y " := ( nateq_decidableProposition x y ) (at level 70, no associativity) : nat_scope.
Notation " x !=? y " := ( natneq_decidableProposition x y ) (at level 70, no associativity) : nat_scope.

Definition decidableChoice {W} : decidableProposition -> W -> W -> W.
Proof.
  intros ? P yes no. induction P as [P dec]. induction (iscontrpr1 dec) as [p|q].
  - exact yes.
  - exact no.
Defined.

Notation "P ? a # b" := (decidableChoice P a b) (at level 100).

Definition tallyStandardSubset {n} (P: decidableSubtype (stn n)) : nat.
Proof. intros. exact (stnsum (λ x, P x ? 1 # 0)).
Defined.

(* verify computability: *)
Goal tallyStandardSubset (λ i:stn 7, 2*i <? 6) = 3. Proof. reflexivity. Defined.
Goal tallyStandardSubset (λ i:stn 7, 2*i =? 6) = 1. Proof. reflexivity. Defined.
Goal tallyStandardSubset (λ i:stn 7, 2*i !=? 4) = 6. Proof. reflexivity. Defined.

(* types and univalence *)

Theorem UU_rect (X Y : UU) (P : X ≃ Y -> UU) :
  (∀ e : X=Y, P (univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (univalence _ _) f)).
  set (h := homotweqinvweq (univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac type_induction f e := generalize f; apply UU_rect; intro e; clear f.

Definition weqbandf' { X Y : UU } (w : X ≃ Y )
           (P:X -> UU) (Q: Y -> UU)
           ( fw : ∀ x:X, P x ≃ Q (w x) ) :
  (Σ x, P x) ≃ (Σ y, Q y).
Proof.
  intros.
  generalize w.
  apply UU_rect; intro e.
  (* this is a case where applying UU_rect is not as good as induction would be... *)
Abort.

Theorem hSet_rect (X Y : hSet) (P : X ≃ Y -> UU) :
  (∀ e : X=Y, P (hSet_univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  Set Printing Coercions.
  set (p := ih (invmap (hSet_univalence _ _) f)).
  set (h := homotweqinvweq (hSet_univalence _ _) f).
  exact (transportf P h p).
  Unset Printing Coercions.
Defined.

Ltac hSet_induction f e := generalize f; apply UU_rect; intro e; clear f.

(** partially ordered sets and ordered sets *)

Definition Poset_univalence_map {X Y:Poset} : X=Y -> PosetEquivalence X Y.
Proof. intros ? ? e. induction e. apply identityPosetEquivalence.
Defined.

Local Arguments isPosetEquivalence : clear implicits.
Local Arguments isaposetmorphism : clear implicits.

Lemma posetStructureIdentity {X:hSet} (R S:po X) :
  @isPosetEquivalence (X,,R) (X,,S) (idweq X) -> R=S.
Proof.
  intros ? ? ? e.
  apply total2_paths_second_isaprop. { apply isaprop_ispo. }
  induction R as [R r]; induction S as [S s]; simpl.
  apply funextfun; intro x; apply funextfun; intro y.
  unfold isPosetEquivalence in e.
  unfold isaposetmorphism in e; simpl in e.
  induction e as [e e'].
  unfold posetRelation in *. unfold invmap in *; simpl in *.
  apply uahp. { apply e. } { apply e'. }
Defined.

Lemma poTransport_logeq {X Y:hSet} (R:po X) (S:po Y) (f:X=Y) :
  @isPosetEquivalence (X,,R) (Y,,S) (hSet_univalence_map _ _ f)
  <-> transportf (po∘pr1hSet) f R = S.
Proof.
  split.
  { intros i. induction f. apply posetStructureIdentity. apply i. }
  { intros e. induction f. induction e. apply isPosetEquivalence_idweq. }
Defined.

Corollary poTransport_weq {X Y:hSet} (R:po X) (S:po Y) (f:X=Y) :
  @isPosetEquivalence (X,,R) (Y,,S) (hSet_univalence_map _ _ f)
  ≃ transportf (po∘pr1hSet) f R = S.
Proof.
  intros. apply weqimplimpl.
  { apply (pr1 (poTransport_logeq _ _ _)). }
  { apply (pr2 (poTransport_logeq _ _ _)). }
  { apply isaprop_isPosetEquivalence. }
  { apply isaset_po. }
Defined.

Local Lemma posetTransport_weq (X Y:Poset) : X≡Y ≃ X≅Y.
Proof.
  intros.
  refine (weqbandf _ _ _ _).
  { apply hSet_univalence. }
  intros e. apply invweq. apply poTransport_weq.
Defined.

Theorem Poset_univalence (X Y:Poset) : X=Y ≃ X≅Y.
Proof.
  intros.
  set (f := @Poset_univalence_map X Y).
  set (g := total2_paths_equiv _ X Y).
  set (h := posetTransport_weq X Y).
  set (f' := weqcomp g h).
  assert (k : pr1weq f' ~ f).
  try reflexivity.              (* this doesn't work *)
  { intro e. apply isinj_pr1_PosetEquivalence. induction e. reflexivity. }
  assert (l : isweq f).
  { apply (isweqhomot f'). exact k. apply weqproperty. }
  exact (f,,l).
Defined.

Definition Poset_univalence_compute {X Y:Poset} (e:X=Y) :
  Poset_univalence X Y e = Poset_univalence_map e.
Proof. reflexivity. Defined.

(* now we try to mimic this construction:

    Inductive PosetEquivalence (X Y:Poset) : Type := 
                  pathToEq : (X=Y) -> PosetEquivalence X Y.

    PosetEquivalence_rect
         : ∀ (X Y : Poset) (P : PosetEquivalence X Y -> Type),
           (∀ e : X = Y, P (pathToEq X Y e)) ->
           ∀ p : PosetEquivalence X Y, P p

*)

Theorem PosetEquivalence_rect (X Y : Poset) (P : X ≅ Y -> UU) :
  (∀ e : X = Y, P (Poset_univalence_map e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (Poset_univalence _ _) f)).
  set (h := homotweqinvweq (Poset_univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac poset_induction f e :=
  generalize f; apply PosetEquivalence_rect; intro e; clear f.

(* applications of poset equivalence induction: *)

Lemma isMinimal_preserved {X Y:Poset} {x:X} (is:isMinimal x) (f:X ≅ Y) :
  isMinimal (f x).
Proof.
  intros.
  (* Anders says " induction f. " should look for PosetEquivalence_rect.  
     Why doesn't it? *)
  poset_induction f e. induction e. simpl. exact is.
Defined.

Lemma isMaximal_preserved {X Y:Poset} {x:X} (is:isMaximal x) (f:X ≅ Y) :
  isMaximal (f x).
Proof. intros. poset_induction f e. induction e. simpl. exact is.
Defined.

Lemma consecutive_preserved {X Y:Poset} {x y:X} (is:consecutive x y) (f:X ≅ Y) : consecutive (f x) (f y).
Proof. intros. poset_induction f e. induction e. simpl. exact is.
Defined.

(** * Ordered sets *)

(** see Bourbaki, Set Theory, III.1, where they are called totally ordered sets *)


Definition isOrdered (X:Poset) := istotal (pr1 (pr2 X)) × isantisymm (pr1 (pr2 X)).

Lemma isaprop_isOrdered (X:Poset) : isaprop (isOrdered X).
Proof.
  intros. apply isapropdirprod. { apply isaprop_istotal. } { apply isaprop_isantisymm. }
Defined.

Definition OrderedSet := Σ X, isOrdered X.

Local Definition underlyingPoset (X:OrderedSet) : Poset := pr1 X.
Coercion underlyingPoset : OrderedSet >-> Poset.

Local Definition underlyingRelation (X:OrderedSet) := pr1 (pr2 (pr1 X)).

Lemma A (X:OrderedSet) : isdeceq X -> ∀ (x y:X), isdecprop (x ≤ y).
Proof.
  intros ? i ? ?.
  apply isdecpropif.
  { apply propproperty. }
  assert (refl := pr2 (pr2 (pr2 (pr1 X))) x); simpl in refl.
  assert (asymm := pr2 (pr2 X) x y).
  assert (total := pr1 (pr2 X) x y).
  change (pr1 (pr2 (pr1 X)) x y) with (x ≤ y) in *.
  change (pr1 (pr2 (pr1 X)) y x) with (y ≤ x) in *.
  change (pr1 (pr2 (pr1 X)) x x) with (x ≤ x) in *.
  set (l := isapropdec (x ≤ y) (pr2 (x ≤ y))).
  change ((x ≤ y)->False) with (¬ (x ≤ y)) in l.
  set (o := total (hProppair _ l)); simpl in o.
  apply o; intro s; clear o l total.
  assert (j := i x y); clear i.
  induction s as [s|s].
  { now apply ii1. }
  induction j as [j|j].
  { apply ii1. rewrite <-j. apply refl. }
  apply ii2.
  intro le.
  apply j.
  now apply asymm.
Defined.

Corollary B (X:OrderedSet) : isfinite X -> ∀ (x y:X), isdecprop (x ≤ y).
Proof. intros ? i ? ?. apply A. now apply isfinite_isdeceq.
Defined.

Corollary C (X:OrderedSet) : isdeceq X -> ∀ (x y:X), isdecprop (x < y).
Proof.
  intros ? i ? ?. apply isdecpropdirprod.
  { now apply A. }
  apply neg_isdecprop. apply isdecpropif.
  { apply setproperty. } apply i.
Defined.

Corollary D (X:OrderedSet) : isfinite X -> ∀ (x y:X), isdecprop (x < y).
Proof. intros ? i ? ?. apply C. now apply isfinite_isdeceq.
Defined.

Delimit Scope oset with oset. 

Notation "X ≅ Y" := (PosetEquivalence X Y) (at level 60, no associativity) : oset.
Notation "m ≤ n" := (underlyingRelation _ m n) (no associativity, at level 70) : oset.
Notation "m < n" := (m ≤ n × m != n)%oset (only parsing) :oset.

Close Scope poset.
Local Open Scope oset.

Lemma isincl_underlyingPoset : isincl underlyingPoset.
Proof.
  apply isinclpr1. intros X. apply isaprop_isOrdered.
Defined.

Lemma isinj_underlyingPoset : isinj underlyingPoset.
Proof.
  apply invmaponpathsincl. apply isincl_underlyingPoset.
Defined.

Definition underlyingPoset_weq (X Y:OrderedSet) :
  X=Y ≃ (underlyingPoset X)=(underlyingPoset Y).
Proof.
  Set Printing Coercions.
  intros. refine (weqpair _ _).
  { apply maponpaths. }
  apply isweqonpathsincl. apply isincl_underlyingPoset.
  Unset Printing Coercions.
Defined.

Theorem OrderedSet_univalence (X Y:OrderedSet) : X=Y ≃ X≅Y.
Proof. intros. exact ((Poset_univalence _ _) ∘ (underlyingPoset_weq _ _))%weq.
Defined.

Theorem OrderedSetEquivalence_rect (X Y : OrderedSet) (P : X ≅ Y -> UU) :
  (∀ e : X = Y, P (OrderedSet_univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (OrderedSet_univalence _ _) f)).
  set (h := homotweqinvweq (OrderedSet_univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac oset_induction f e := generalize f; apply OrderedSetEquivalence_rect; intro e; clear f.
  
(* standard ordered sets *)

Definition FiniteOrderedSet := Σ X:OrderedSet, isfinite X.
Definition underlyingOrderedSet (X:FiniteOrderedSet) : OrderedSet := pr1 X.
Coercion underlyingOrderedSet : FiniteOrderedSet >-> OrderedSet.
Definition finitenessProperty (X:FiniteOrderedSet) : isfinite X := pr2 X.

Definition standardFiniteOrderedSet (n:nat) : FiniteOrderedSet.
Proof.
  intros.
  refine (_,,_).
  { exists (stnposet n). split.
    { intros x y. apply istotalnatleh. }
    intros ? ? ? ?. apply isinjstntonat. now apply isantisymmnatleh. }
  { apply isfinitestn. }
Defined.

Local Notation "⟦ n ⟧" := (standardFiniteOrderedSet n) (at level 0).
(* in agda-mode \[[ n \]] *)

Definition FiniteStructure (X:OrderedSet) := Σ n, ⟦ n ⟧ ≅ X.

Lemma subsetFiniteness {X} (P : decidableSubtype X) : isfinite X -> isfinite P.
Proof.
  intros ? ? isfin.
  apply isfin; intro fin; clear isfin.
  induction fin as [m w].
  unfold nelstruct in w.
  apply hinhpr.
  unfold finstruct.
  exists (tallyStandardSubset (P ∘ w)).
  { unfold nelstruct.
    




Abort.

Local Lemma std_auto n : iscontr (⟦ n ⟧ ≅ ⟦ n ⟧).
Proof.
  intros. exists (identityPosetEquivalence _). intros f.
  apply total2_paths_isaprop.
  { intros g. apply isaprop_isPosetEquivalence. }
  simpl. apply isinjpr1weq. simpl. apply funextfun. intros i.
    

Abort.

Lemma isapropFiniteStructure X : isaprop (FiniteStructure X).
Proof.
  intros.
  apply invproofirrelevance; intros r s.
  destruct r as [m p].
  destruct s as [n q].
  apply total2_paths2_second_isaprop.
  { 
    apply weqtoeqstn.
    exact (weqcomp (pr1 p) (invweq (pr1 q))).
  }
  {
    intros k.
    apply invproofirrelevance; intros [[r b] i] [[s c] j]; simpl in r,s,i,j.
    apply total2_paths2_second_isaprop.
    { 
      apply total2_paths2_second_isaprop.
      { 
        
        
        
        admit. }
      apply isapropisweq. }
    apply isaprop_isPosetEquivalence.
  }
Abort.

Theorem enumeration_FiniteOrderedSet (X:FiniteOrderedSet) : iscontr (FiniteStructure X).
Proof.
  intros.
  refine (_,,_).
  { exists (fincard (finitenessProperty X)).

Abort.

