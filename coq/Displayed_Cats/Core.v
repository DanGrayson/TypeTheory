(**
A module for “displayed precategories”, based over UniMath’s [CategoryTheory] library.

Roughly, a “displayed category _D_ over a precategory _C_” is analogous to “a family of types _Y_ indexed over a type _X_”.  A displayed category has a “total category” Σ _C_ _D_, with a functor to _D_; and indeed displayed categories should be equivalent to categories over _D_, by taking fibres.

In a little more detail: if [D] is a displayed precategory over [C], then [D] has a type of objects indexed over [ob C], and for each [x y : C, f : x ⇒ y, xx : D x, yy : D y], a type of “morphisms over [f] from [xx] to [yy]”.  The identity and composition (and axioms) for [D] all overlie the corresponding structure on [C].

Two major motivations for displayed categories:

- Pragmatically, they give a convenient tool for building categories of “structured objects”, and functors into such categories, encapsulating a lot of frequently-used constructions, and allowing for very modular proofs of e.g. saturation of such categories.
- More conceptually, they give a setting for defining Grothendieck fibrations and isofibrations without mentioning equality of objects.

** Contents:

- Displayed precategories: [disp_precat C]
- Total precategories (and their forgetful functors)
  - [total_precat D]
  - [pr1_precat D]
- Functors between precategories, over functors between their bases
  - [functor_lifting], [lifted_functor]
  - [functor_over], [total_functor]
  - properties of functors: [functor_over_ff], …
  - natural transformations: [nat_trans_over], …
- Fibrations
*)

Require Import UniMath.Foundations.Basics.Sets.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.

Require UniMath.Ktheory.Utilities.

Require Import Systems.Auxiliary.
Require Import Systems.UnicodeNotations.
Require Import Systems.Displayed_Cats.Auxiliary.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

Local Open Scope type_scope.

Undelimit Scope transport.

(** * Displayed precategories *)

Module Record_Preview.

  Record disp_precat (C : Precategory) : Type :=
    { ob_disp : C -> Type
    ; mor_disp {x y : C} : (x ⇒ y) -> ob_disp x -> ob_disp y -> Type
    ; id_disp {x : C} (xx : ob_disp x) : mor_disp (identity x) xx xx
    ; comp_disp {x y z : C} {f : x ⇒ y} {g : y ⇒ z}
                   {xx : ob_disp x} {yy : ob_disp y} {zz : ob_disp z}
        : mor_disp f xx yy -> mor_disp g yy zz -> mor_disp (f ;; g) xx zz
    ; id_left_disp {x y} {f : x ⇒ y} {xx} {yy} (ff : mor_disp f xx yy)
        : comp_disp (id_disp xx) ff
          = transportb (fun g => mor_disp g xx yy) (id_left _) ff
    ; id_right_disp {x y} {f : x ⇒ y} {xx} {yy} (ff : mor_disp f xx yy)
        : comp_disp ff (id_disp yy)
          = transportb (fun g => mor_disp g xx yy) (id_right _) ff
    ; assoc_disp {x y z w} {f : x ⇒ y} {g : y ⇒ z} {h : z ⇒ w}
        {xx} {yy} {zz} {ww}
        (ff : mor_disp f xx yy) (gg : mor_disp g yy zz) (hh : mor_disp h zz ww)
        : comp_disp ff (comp_disp gg hh)
          = transportb (fun k => mor_disp k _ _) (assoc _ _ _)
            (comp_disp (comp_disp ff gg) hh)
    ; homsets_disp {x y} {f : x ⇒ y} {xx} {yy} : isaset (mor_disp f xx yy) 
    }.

End Record_Preview.

(** The actual definition is structured analogously to [precategory], as an iterated Σ-type:

- [disp_precat]
  - [disp_precat_data]
    - [disp_precat_ob_mor]
      - [ob_disp]
      - [mod_disp]
    - [disp_precat_id_comp]
      - [id_disp]
      - [comp_disp]
  - [disp_precat_axioms]
    - [id_left_disp]
    - [id_right_disp]
    - [assoc_disp]
    - [homsets_disp]

*)

Section Disp_Precat.

Definition disp_precat_ob_mor (C : precategory_ob_mor)
  := Σ (obd : C -> Type), (Π x y:C, obd x -> obd y -> (x ⇒ y) -> Type).

Definition ob_disp {C} (D : disp_precat_ob_mor C) : C -> UU := pr1 D.
Coercion ob_disp : disp_precat_ob_mor >-> Funclass.

Definition mor_disp {C} {D : disp_precat_ob_mor C}
  {x y} xx yy (f : x ⇒ y)
:= pr2 D x y xx yy f : Type. 

Local Notation "xx ⇒[ f ] yy" := (mor_disp xx yy f) (at level 50, yy at next level).

Definition disp_precat_id_comp (C : precategory_data)
  (D : disp_precat_ob_mor C)
  : Type
:= (forall (x:C) (xx : D x), xx ⇒[identity x] xx)
  × (forall (x y z : C) (f : x ⇒ y) (g : y ⇒ z) (xx:D x) (yy:D y) (zz:D z),
           (xx ⇒[f] yy) -> (yy ⇒[g] zz) -> (xx ⇒[f ;; g] zz)).

Definition disp_precat_data C := total2 (disp_precat_id_comp C).

Definition disp_precat_ob_mor_from_disp_precat_data {C}
  (D : disp_precat_data C)
  : disp_precat_ob_mor C
:= pr1 D.

Coercion disp_precat_ob_mor_from_disp_precat_data : 
 disp_precat_data >-> disp_precat_ob_mor.

Definition id_disp {C} {D : disp_precat_data C} {x:C} (xx : D x)
  : xx ⇒[identity x] xx
:= pr1 (pr2 D) x xx.

Definition comp_disp {C} {D : disp_precat_data C}
  {x y z : C} {f : x ⇒ y} {g : y ⇒ z}
  {xx : D x} {yy} {zz} (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : xx ⇒[f;;g] zz
:= pr2 (pr2 D) _ _ _ _ _ _ _ _ ff gg.

Local Notation "ff ;; gg" := (comp_disp ff gg)
  (at level 50, left associativity, format "ff  ;;  gg")
  : mor_disp_scope.
Delimit Scope mor_disp_scope with mor_disp.
Bind Scope mor_disp_scope with mor_disp.
Local Open Scope mor_disp_scope.

Definition disp_precat_axioms (C : Precategory) (D : disp_precat_data C)
  : Type
:= (Π x y (f : x ⇒ y) (xx : D x) yy (ff : xx ⇒[f] yy),
     id_disp _ ;; ff
     = transportb _ (id_left _) ff)
   × (Π x y (f : x ⇒ y) (xx : D x) yy (ff : xx ⇒[f] yy),
     ff ;; id_disp _
     = transportb _ (id_right _) ff)
   × (Π x y z w f g h (xx : D x) (yy : D y) (zz : D z) (ww : D w)
        (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz) (hh : zz ⇒[h] ww),
     ff ;; (gg ;; hh)
     = transportb _ (assoc _ _ _) ((ff ;; gg) ;; hh))
   × (Π x y f (xx : D x) (yy : D y), isaset (xx ⇒[f] yy)).

Definition disp_precat (C : Precategory) := total2 (disp_precat_axioms C).

Definition disp_precat_data_from_disp_precat {C} (D : disp_precat C)
 := pr1 D : disp_precat_data C.
Coercion disp_precat_data_from_disp_precat : disp_precat >-> disp_precat_data.

Definition id_left_disp {C} {D : disp_precat C} 
  {x y} {f : x ⇒ y} {xx : D x} {yy} {ff : xx ⇒[f] yy}
: id_disp _ ;; ff = transportb _ (id_left _) ff
:= pr1 (pr2 D) _ _ _ _ _ _.

Definition id_right_disp {C} {D : disp_precat C} 
  {x y} {f : x ⇒ y} {xx : D x} {yy} {ff : xx ⇒[f] yy}
  : ff ;; id_disp _ = transportb _ (id_right _) ff
:= pr1 (pr2 (pr2 D)) _ _ _ _ _ _.

Definition assoc_disp {C} {D : disp_precat C}
  {x y z w} {f} {g} {h} {xx : D x} {yy : D y} {zz : D z} {ww : D w}
  {ff : xx ⇒[f] yy} {gg : yy ⇒[g] zz} {hh : zz ⇒[h] ww}
: ff ;; (gg ;; hh) = transportb _ (assoc _ _ _) ((ff ;; gg) ;; hh)
:= pr1 (pr2 (pr2 (pr2 D))) _ _ _ _ _ _ _ _ _ _ _ _ _ _.

Definition assoc_disp_var {C} {D : disp_precat C}
  {x y z w} {f} {g} {h} {xx : D x} {yy : D y} {zz : D z} {ww : D w}
  (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz) (hh : zz ⇒[h] ww)
: (ff ;; gg) ;; hh = transportf _ (assoc _ _ _) (ff ;; (gg ;; hh)).
Proof.
  apply pathsinv0, Utilities.transportf_pathsinv0.
  apply pathsinv0, assoc_disp.
Defined.

Definition homsets_disp {C} {D :disp_precat C} {x y} {f} {xx : D x} {yy : D y}
  : isaset (xx ⇒[f] yy)
:= pr2 (pr2 (pr2 (pr2 D))) _ _ _ _ _.

(** ** Some utility lemmas *)
Section Lemmas.

Lemma isaprop_disp_precat_axioms (C : Precategory) (D : disp_precat_data C)
  : isaprop (disp_precat_axioms C D).
Proof.
  apply isofhlevelsn.
  intro X.
  set (XR := ( _ ,, X) : disp_precat C).
  apply isofhleveltotal2.
  - repeat (apply impred; intro).
    apply (@homsets_disp _ XR).
  - intros x.
    repeat (apply isofhleveldirprod); repeat (apply impred; intro).
    + apply (@homsets_disp _ XR).
    + apply (@homsets_disp _ XR).
    + apply isapropiscontr.
Qed.
      
Lemma compl_disp_transp {C : Precategory} {D : disp_precat_data C}
    {x y z : C} {f f' : x ⇒ y} (ef : f = f') {g : y ⇒ z}
    {xx : D x} {yy} {zz} (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : (transportf _ ef ff) ;; gg
  = transportf _ (maponpaths (fun k => k ;; _)%mor ef) (ff ;; gg).
Proof.
  destruct ef. apply idpath.
Qed.

(* TODO: consider naming of following few transport lemmas *)
Lemma mor_disp_transportf_postwhisker
    {C : precategory} {D : disp_precat_data C}
    {x y z : C} {f f' : x ⇒ y} (ef : f = f') {g : y ⇒ z}
    {xx : D x} {yy} {zz} (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : (transportf _ ef ff) ;; gg
  = transportf _ (cancel_postcomposition _ _ g ef) (ff ;; gg).
Proof.
  destruct ef; apply idpath.
Qed.

Lemma mor_disp_transportf_prewhisker
    {C : precategory} {D : disp_precat_data C}
    {x y z : C} {f : x ⇒ y} {g g' : y ⇒ z} (eg : g = g')
    {xx : D x} {yy} {zz} (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : ff ;; (transportf _ eg gg)
  = transportf _ (maponpaths (compose f) eg) (ff ;; gg).
Proof.
  destruct eg; apply idpath.
Qed.

(* TODO: unify with [mor_disp_transportf_prewhisker] *)
Lemma compr_disp_transp {C : Precategory} {D : disp_precat_data C}
    {x y z : C} {f : x ⇒ y} {g g' : y ⇒ z} (eg : g = g')
    {xx : D x} {yy} {zz} (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : ff ;; (transportf _ eg gg)
  = transportf _ (maponpaths (fun k => _ ;; k)%mor eg) (ff ;; gg).
Proof.
  apply mor_disp_transportf_prewhisker.
Qed.

End Lemmas.

End Disp_Precat.

(** Redeclare sectional notations globally. *)
Notation "xx ⇒[ f ] yy" := (mor_disp xx yy f) (at level 50, yy at next level).

Notation "ff ;; gg" := (comp_disp ff gg)
  (at level 50, left associativity, format "ff  ;;  gg")
  : mor_disp_scope.
Delimit Scope mor_disp_scope with mor_disp.
Bind Scope mor_disp_scope with mor_disp.
Local Open Scope mor_disp_scope.

(** * Isomorphisms and (saturated) categories *)

Section Isos.

Definition is_iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} (f : iso x y) {xx : D x} {yy} (ff : xx ⇒[f] yy)
  : Type
:= Σ (gg : yy ⇒[inv_from_iso f] xx),
     gg ;; ff = transportb _ (iso_after_iso_inv _) (id_disp _)
     × ff ;; gg = transportb _ (iso_inv_after_iso _) (id_disp _).

Definition iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} (f : iso x y) (xx : D x) (yy : D y)
  := Σ ff : xx ⇒[f] yy, is_iso_disp f ff.

Definition mor_disp_from_iso {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    (i : iso_disp f xx yy) : _ ⇒[ _ ] _ := pr1 i.
Coercion mor_disp_from_iso : iso_disp >-> mor_disp.

Definition is_iso_disp_from_iso {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y}
    (i : iso_disp f xx yy) : is_iso_disp f i := pr2 i.
Coercion is_iso_disp_from_iso : iso_disp >-> is_iso_disp.

Definition inv_mor_disp_from_iso {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    {ff : xx ⇒[f] yy} (i : is_iso_disp f ff)
  : _ ⇒[ _ ] _ := pr1 i.

Definition iso_disp_after_inv_mor {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    {ff : xx ⇒[f] yy} (i : is_iso_disp f ff)
  : inv_mor_disp_from_iso i ;; ff
    = transportb _ (iso_after_iso_inv _) (id_disp _).
Proof.
  apply (pr2 i).
Qed.

Definition inv_mor_after_iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    {ff : xx ⇒[f] yy} (i : is_iso_disp f ff)
  : ff ;; inv_mor_disp_from_iso i
    = transportb _ (iso_inv_after_iso _) (id_disp _).
Proof.
  apply (pr2 (pr2 i)).
Qed.

Lemma isaprop_is_iso_disp {C : Precategory} {D : disp_precat C}
    {x y : C} (f : iso x y) {xx : D x} {yy} (ff : xx ⇒[f] yy)
  : isaprop (is_iso_disp f ff).
Proof.
  apply invproofirrelevance; intros i i'.
  apply subtypeEquality.
  - intros gg. apply isapropdirprod; apply homsets_disp.
  (* uniqueness of inverses *)
  (* TODO: think about better lemmas for this sort of calculation?
  e.g. all that repeated application of [transport_f_f], etc. *)
  - destruct i as [gg [gf fg]], i' as [gg' [gf' fg']]; simpl.
    etrans. eapply pathsinv0, Utilities.transportfbinv.
    etrans. apply maponpaths, @pathsinv0, id_right_disp.
    etrans. apply maponpaths, maponpaths.
      etrans. eapply pathsinv0, Utilities.transportfbinv.
      apply maponpaths, @pathsinv0, fg'.
    etrans. apply maponpaths, mor_disp_transportf_prewhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths, assoc_disp.
    etrans. apply transport_f_f.
    etrans. apply maponpaths, maponpaths_2, gf.
    etrans. apply maponpaths, mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths, id_left_disp.
    etrans. apply transport_f_f.
    refine (@maponpaths_2 _ _ _ (transportf _) _ (idpath _) _ _).
    apply homset_property.
Qed.

Lemma eq_iso_disp {C : Precategory} {D : disp_precat C}
    {x y : C} (f : iso x y) 
    {xx : D x} {yy} (ff ff' : iso_disp f xx yy)
  : pr1 ff = pr1 ff' -> ff = ff'.
Proof.
  apply subtypeEquality; intro; apply isaprop_is_iso_disp.
Qed.

Lemma is_iso_disp_transportf {C : Precategory} {D : disp_precat C}
    {x y : C} {f f' : iso x y} (e : f = f')
    {xx : D x} {yy} {ff : xx ⇒[f] yy}
    (is : is_iso_disp _ ff)
  : is_iso_disp f' (transportf _ (maponpaths _ e) ff).
Proof.
  induction e.
  apply is.
Qed.

Definition is_iso_inv_from_iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    (i : iso_disp f xx yy) 
    :
    is_iso_disp (iso_inv_from_iso f) (inv_mor_disp_from_iso i).
Proof.
  mkpair.
  - change ( xx ⇒[ iso_inv_from_iso (iso_inv_from_iso f)] yy).    
    set (XR := transportb (mor_disp xx yy ) 
                          (maponpaths pr1 (iso_inv_iso_inv _ _ _ f))).
    apply XR. apply i.
  - cbn.
    split.
    + abstract (
      etrans ;[ apply mor_disp_transportf_postwhisker |];
      etrans ;[ apply maponpaths; apply inv_mor_after_iso_disp |];
      etrans ;[ apply transport_f_f |];
      apply transportf_comp_lemma; apply transportf_comp_lemma_hset;
      try apply homset_property; apply idpath ).
    + abstract (
      etrans ;[ apply mor_disp_transportf_prewhisker |];
      etrans ;[ apply maponpaths; apply iso_disp_after_inv_mor |];
      etrans ;[ apply transport_f_f |];
      apply transportf_comp_lemma; apply transportf_comp_lemma_hset;
      try apply homset_property; apply idpath ).
Defined.

Definition is_iso_inv_from_is_iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    (ff : xx ⇒[f] yy)
    (i : is_iso_disp f ff) 
    :
    is_iso_disp (iso_inv_from_iso f) (inv_mor_disp_from_iso i).
Proof.
  apply (is_iso_inv_from_iso_disp (ff ,, i)).
Defined.

Definition iso_inv_from_iso_disp {C : Precategory} {D : disp_precat_data C}
    {x y : C} {f : iso x y}{xx : D x} {yy : D y} 
    (i : iso_disp f xx yy) 
    :
    iso_disp (iso_inv_from_iso f) yy xx.
Proof.
  exists (inv_mor_disp_from_iso i).
  apply is_iso_inv_from_iso_disp.
Defined.

Definition iso_disp_comp {C : Precategory} {D : disp_precat C}
    {x y z : C} {f : iso x y} {g : iso y z} {xx : D x} {yy : D y} {zz : D z}
    (ff : iso_disp f xx yy) (gg : iso_disp g yy zz) 
    :
    iso_disp (iso_comp f g) xx zz.
Proof.
  mkpair.
  - apply (ff ;; gg).
  - mkpair.
    + Search (iso_inv_from_iso (iso_comp _ _ ) = _ ).
      apply (transportb (mor_disp zz xx) (maponpaths pr1 (iso_inv_of_iso_comp _ _ _ _ f g))).
      cbn.
      apply (inv_mor_disp_from_iso gg ;; inv_mor_disp_from_iso ff).
    + split.
      * etrans.  apply mor_disp_transportf_postwhisker.
        etrans. apply maponpaths. apply assoc_disp_var.
        etrans. apply maponpaths, maponpaths, maponpaths.
                apply assoc_disp.
        etrans. apply maponpaths, maponpaths, maponpaths, maponpaths.
                eapply (maponpaths (fun x => x ;; gg)).
                apply iso_disp_after_inv_mor.
        etrans. apply transport_f_f.
        etrans. apply maponpaths. apply mor_disp_transportf_prewhisker.
        etrans.  apply transport_f_f. 
        etrans. apply maponpaths, maponpaths. 
          apply mor_disp_transportf_postwhisker.
        etrans. apply maponpaths. apply mor_disp_transportf_prewhisker. 
        etrans. apply transport_f_f. 
        etrans. apply maponpaths, maponpaths. apply id_left_disp.
        etrans. apply maponpaths. apply mor_disp_transportf_prewhisker. 
        etrans. apply transport_f_f. 
        etrans. apply maponpaths.        apply iso_disp_after_inv_mor.
        etrans. apply transport_f_f. 
        apply transportf_comp_lemma; apply transportf_comp_lemma_hset;
        try apply homset_property; apply idpath.
      * cbn. simpl.
        etrans. apply assoc_disp_var. 
        etrans. apply maponpaths, maponpaths.
                 apply mor_disp_transportf_prewhisker. 
        etrans. apply maponpaths, maponpaths, maponpaths.
                apply assoc_disp.
        etrans. apply maponpaths, maponpaths, maponpaths, maponpaths.
                eapply (maponpaths (fun x => x ;; inv_mor_disp_from_iso ff )).
                apply inv_mor_after_iso_disp.
        etrans. apply maponpaths, maponpaths, maponpaths, maponpaths.
                 apply mor_disp_transportf_postwhisker. 
        etrans. apply maponpaths, maponpaths, maponpaths, maponpaths, maponpaths.
                apply id_left_disp.
        etrans. apply maponpaths, maponpaths. apply transport_f_f.
        etrans. apply maponpaths, maponpaths. apply transport_f_f.
        etrans.  apply maponpaths, maponpaths. apply transport_f_f.
        etrans. apply maponpaths. apply mor_disp_transportf_prewhisker. 
        etrans. apply transport_f_f.
        etrans. apply maponpaths.                apply inv_mor_after_iso_disp.
        etrans. apply transport_f_f.
        apply transportf_comp_lemma; apply transportf_comp_lemma_hset;
        try apply homset_property; apply idpath.
Defined.

Definition id_is_iso_disp {C} {D : disp_precat C} {x : C} (xx : D x)
  : is_iso_disp (identity_iso x) (id_disp xx).
Proof.
  exists (id_disp _); split.
  - etrans. apply id_left_disp.
    apply maponpaths_2, homset_property.
  - etrans. apply id_left_disp.
    apply maponpaths_2, homset_property.
Defined.

Definition identity_iso_disp {C} {D : disp_precat C} {x : C} (xx : D x)
  : iso_disp (identity_iso x) xx xx
:= (_ ,, id_is_iso_disp _).

Lemma idtoiso_disp {C} {D : disp_precat C}
    {x x' : C} (e : x = x')
    {xx : D x} {xx' : D x'} (ee : transportf _ e xx = xx')
  : iso_disp (idtoiso e) xx xx'.
Proof.
  destruct e, ee; apply identity_iso_disp.
Defined.

Lemma idtoiso_fiber_disp {C} {D : disp_precat C} {x : C}
    {xx xx' : D x} (ee : xx = xx')
  : iso_disp (identity_iso x) xx xx'.
Proof.
  exact (idtoiso_disp (idpath _) ee).
Defined.


Lemma iso_disp_precomp {C : Precategory} {D : disp_precat C}
    {x y : C} (f : iso x y) 
    {xx : D x} {yy} (ff : iso_disp f xx yy)
  : forall (y' : C) (f' : y ⇒ y') (yy' : D y'), 
          isweq (fun ff' : yy ⇒[ f' ] yy' => pr1 ff ;; ff').
Proof.
  intros y' f' yy'.
  use gradth.
  + intro X.
    set (XR := (pr1 (pr2 ff)) ;; X).
    set (XR' := transportf _ (assoc _ _ _   ) XR).
(*    Search (inv_from_iso _  ). *)
    set (XRRT := transportf _ 
           (maponpaths (fun xyz => (xyz ;; f')%mor) (iso_after_iso_inv f)) 
           XR').
    set (XRRT' := transportf _ (id_left _ )                   
           XRRT).
    apply XRRT'.
  + intros. simpl.
    etrans. apply transport_f_f.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply assoc_disp.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply maponpaths_2. apply (pr2 (pr2 ff)). 
    etrans. apply maponpaths. apply mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply id_left_disp.
    etrans. apply transport_f_f.
    apply transportf_comp_lemma_hset.
    apply (pr2 C). apply idpath.
  + intros; simpl.
    etrans. apply maponpaths. apply transport_f_f.
    etrans. apply mor_disp_transportf_prewhisker.
    etrans. apply maponpaths. apply mor_disp_transportf_prewhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply assoc_disp.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply maponpaths_2. 
    assert (XR := pr2 (pr2 (pr2 ff))). simpl in XR. apply XR.
    etrans. apply maponpaths. apply mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply id_left_disp.
    etrans. apply transport_f_f.
    apply transportf_comp_lemma_hset.
    apply (pr2 C). apply idpath.
Defined.

End Isos.

Section Categories.

(** The current [is_category_disp] is certainly the correct definition in the case where the base precategory [C] is a category.

When [C] is a general precategory, it’s not quite clear if this definition is correct, or if some other definition might be better. *)

Definition is_category_disp {C} (D : disp_precat C)
  := forall x x' (e : x = x') {xx : D x} {xx' : D x'},
       isweq (λ ee, @idtoiso_disp _ _ _ _ e xx xx' ee).


Lemma is_category_disp_from_fibers {C} {D : disp_precat C}
  : (Π x (xx xx' : D x), isweq (fun e : xx = xx' => idtoiso_fiber_disp e))
  -> is_category_disp D.
Proof.
  intros H x x' e. destruct e. apply H.
Qed.

Definition disp_category {C}
  := Σ D : disp_precat C, is_category_disp D.

End Categories.


(** * Total category *)

(* Any displayed precategory has a total precategory, with a forgetful functor to the base category. *)
Section Total_Precat.

Context {C : Precategory} (D : disp_precat C).

Definition total_precat_ob_mor : precategory_ob_mor.
Proof.
  exists (Σ x:C, D x).
  intros xx yy.
  (* note: we use projections rather than destructing, so that [ xx ⇒ yy ] 
  can β-reduce without [xx] and [yy] needing to be in whnf *) 
  exact (Σ (f : pr1 xx ⇒ pr1 yy), pr2 xx ⇒[f] pr2 yy).
Defined.

Definition total_precat_id_comp : precategory_id_comp (total_precat_ob_mor).
Proof.
  apply tpair; simpl.
  - intros. exists (identity _). apply id_disp.
  - intros xx yy zz ff gg.
    exists (pr1 ff ;; pr1 gg)%mor.
    exact (pr2 ff ;; pr2 gg).
Defined.

Definition total_precat_data : precategory_data
  := (total_precat_ob_mor ,, total_precat_id_comp).

(* TODO: make notations [( ,, )] and [ ;; ] different levels?  ;; should bind tighter, perhaps, and ,, looser? *)
Lemma total_precat_is_precat : is_precategory (total_precat_data).
Proof.
  repeat apply tpair; simpl.
  - intros xx yy ff; cbn.
    use total2_paths; simpl.
    apply id_left.
    eapply pathscomp0.
      apply maponpaths, id_left_disp.
  (* Note: [transportbfinv] is from [UniMath.Ktheory.Utilities].
  We currently can’t import that, due to notation clashes. *)
    apply Utilities.transportfbinv. 
  - intros xx yy ff; cbn.
    use total2_paths; simpl.
    apply id_right.
    eapply pathscomp0.
      apply maponpaths, id_right_disp.
    apply Utilities.transportfbinv. 
  - intros xx yy zz ww ff gg hh.
    use total2_paths; simpl.
    apply assoc.
    eapply pathscomp0.
      apply maponpaths, assoc_disp.
    apply Utilities.transportfbinv. 
Qed.

(* The “pre-pre-category” version, without homsets *)
Definition total_precat_pre : precategory
  := (total_precat_data ,, total_precat_is_precat).

Lemma total_precat_has_homsets : has_homsets (total_precat_data).
Proof.
  intros xx yy; simpl. apply isaset_total2. apply homset_property.
  intros; apply homsets_disp.
Qed.

Definition total_precat : Precategory
  := (total_precat_pre ,, total_precat_has_homsets).

(** ** Forgetful functor *)

Definition pr1_precat_data : functor_data total_precat C.
Proof.
  exists pr1.
  intros a b; exact pr1.
Defined.

Lemma pr1_precat_is_functor : is_functor pr1_precat_data.
Proof.
  apply tpair.
  - intros x; apply idpath.
  - intros x y z f g; apply idpath.
Qed.  

Definition pr1_precat : functor total_precat C
  := (pr1_precat_data ,, pr1_precat_is_functor).

(** ** Isomorphisms and saturation in the total category *)

(* TODO: define, and sub in, [inv_from_iso_disp], and other access functions. *)

Definition is_iso_total {xx yy : total_precat} (ff : xx ⇒ yy)
  (i : is_iso (pr1 ff))
  (fi := isopair (pr1 ff) i)
  (ii : is_iso_disp fi (pr2 ff))
  : is_iso ff.
Proof.
  apply (@is_iso_qinv total_precat xx yy _ 
           (inv_from_iso fi,, pr1 ii)).
  split.
  - use total2_paths.
    apply (iso_inv_after_iso fi).
    etrans. apply maponpaths. apply (pr2 (pr2 ii)).
    apply Utilities.transportfbinv.
  - use total2_paths.
    apply (iso_after_iso_inv fi).
    etrans. apply maponpaths. apply (pr1 (pr2 ii)).
    apply Utilities.transportfbinv.
Qed.

Definition is_iso_base_from_total {xx yy : total_precat} {ff : xx ⇒ yy} (i : is_iso ff)
  : is_iso (pr1 ff).
Proof.  
  set (ffi := isopair ff i).
  apply (is_iso_qinv _ (pr1 (inv_from_iso ffi))).
  split.
  - exact (maponpaths pr1 (iso_inv_after_iso ffi)).
  - exact (maponpaths pr1 (iso_after_iso_inv ffi)).
Qed.

Definition iso_base_from_total {xx yy : total_precat} (ffi : iso xx yy)
  : iso (pr1 xx) (pr1 yy)
:= isopair _ (is_iso_base_from_total (pr2 ffi)).

Definition inv_iso_base_from_total {xx yy : total_precat} (ffi : iso xx yy)
  : inv_from_iso (iso_base_from_total ffi) = pr1 (inv_from_iso ffi).
Proof.
  apply pathsinv0, inv_iso_unique'. unfold precomp_with.
  exact (maponpaths pr1 (iso_inv_after_iso ffi)).
Qed.

Definition is_iso_disp_from_total {xx yy : total_precat}
    {ff : xx ⇒ yy} (i : is_iso ff)
    (ffi := isopair ff i)
  : is_iso_disp (iso_base_from_total (ff,,i)) (pr2 ff).
Proof.  
  mkpair; [ | split].
  - eapply transportb. apply inv_iso_base_from_total.
    exact (pr2 (inv_from_iso ffi)).
  - etrans. apply mor_disp_transportf_postwhisker.
    etrans. apply maponpaths, @pathsinv0.
      exact (fiber_paths (!iso_after_iso_inv ffi)).
    etrans. apply transport_f_f.
    refine (toforallpaths _ _ _ _ (id_disp _)).
    unfold transportb; apply maponpaths, homset_property.
  - etrans. apply mor_disp_transportf_prewhisker.
    etrans. apply maponpaths, @pathsinv0.
      exact (fiber_paths (!iso_inv_after_iso ffi)).
    etrans. apply transport_f_f.
    refine (toforallpaths _ _ _ _ (id_disp _)).
    unfold transportb; apply maponpaths, homset_property.
Qed.

Definition iso_disp_from_total {xx yy : total_precat}
    (ff : iso xx yy)
  : iso_disp (iso_base_from_total ff) (pr2 xx) (pr2 yy). 
Proof.
  exact (_,, is_iso_disp_from_total (pr2 ff)).
Defined.

Definition total_iso {xx yy : total_precat}
  (f : iso (pr1 xx) (pr1 yy)) (ff : iso_disp f (pr2 xx) (pr2 yy))
  : iso xx yy.
Proof.
  exists (pr1 f,, pr1 ff).
  apply (is_iso_total (pr1 f,, pr1 ff) (pr2 f) (pr2 ff)).
Defined.

Definition total_iso_equiv_map {xx yy : total_precat}
  : (Σ f : iso (pr1 xx) (pr1 yy), iso_disp f (pr2 xx) (pr2 yy))
  -> iso xx yy
:= fun ff => total_iso (pr1 ff) (pr2 ff).

(* TODO: make an uncurried version of this above, as [transportf_iso_disp]? *)
Lemma transportf_iso_disp' {xx yy : total_precat} 
    {f f' : iso (pr1 xx) (pr1 yy)} (e : f = f')
    (ff : iso_disp f (pr2 xx) (pr2 yy))
  : pr1 (transportf (fun g => iso_disp g _ _) e ff)
  = transportf _ (base_paths _ _ e) (pr1 ff).
Proof.
  destruct e; apply idpath.
Qed.

Definition total_iso_isweq (xx yy : total_precat)
  : isweq (@total_iso_equiv_map xx yy).
Proof.
  use gradth.
  - intros ff. exists (iso_base_from_total ff). apply iso_disp_from_total.
  - intros [f ff]. use total2_paths.
    + apply eq_iso, idpath.
    + apply eq_iso_disp.
      etrans. apply transportf_iso_disp'.
      simpl pr2. simpl (pr1 (iso_disp_from_total _)).
      refine (@maponpaths_2 _ _ _ (transportf _) _ (idpath _) _ _). 
      apply homset_property.
  - intros f. apply eq_iso; simpl.
    destruct f as [[f ff] w]; apply idpath.
Qed.

Definition total_iso_equiv (xx yy : total_precat)
  : (Σ f : iso (pr1 xx) (pr1 yy), iso_disp f (pr2 xx) (pr2 yy))
  ≃ iso xx yy
:= weqpair _ (total_iso_isweq xx yy).

Lemma is_category_total_category (CC : is_category C) (DD : is_category_disp D)
  : is_category (total_precat).
Proof.
  split. Focus 2. apply homset_property.
  intros xs ys.
  set (x := pr1 xs). set (xx := pr2 xs).  
  set (y := pr1 ys). set (yy := pr2 ys). 
  assert (lemma : 
   Π (A B : Type) (f : A -> B) (w : A ≃ B) (H : w ~ f), isweq f).
  {
    intros A B f w H. apply isweqhomot with w. apply H. apply weqproperty.
  }
  use lemma.
  apply (@weqcomp _ (Σ e : x = y, transportf _ e xx = yy) _).
    apply total2_paths_equiv.
  apply (@weqcomp _ (Σ e : x = y, iso_disp (idtoiso e) xx yy) _).
    apply weqfibtototal. 
    intros e. exists (fun ee => idtoiso_disp e ee). 
    apply DD.
  apply (@weqcomp _ (Σ f : iso x y, iso_disp f xx yy) _).
    refine (weqfp (weqpair _ _) _). apply CC.
  apply total_iso_equiv.
  intros e; destruct e; apply eq_iso; cbn.
    apply idpath.
Qed.

End Total_Precat.

Arguments pr1_precat [C] D.

(** * Functors 

- Reindexing of displayed precats along functors: [reindex_disp_precat]
- Functors into displayed precats, lifting functors into the base: [functor_lifting]
- Functors between displayed precats, over functors between the bases: [functor_over]
- Natural transformations between these: [nat_trans_over] *)

(** ** Reindexing *)

Section Reindexing.

Context {C' C : Precategory} (F : functor C' C) (D : disp_precat C).

Definition reindex_disp_precat_ob_mor : disp_precat_ob_mor C'.
Proof.
  exists (fun c => D (F c)).
  intros x y xx yy f. exact (xx ⇒[# F f] yy).
Defined.

Definition reindex_disp_precat_id_comp : disp_precat_id_comp C' reindex_disp_precat_ob_mor.
Proof.
  apply tpair.
  - simpl; intros x xx.
    refine (transportb _ _ _).
    apply functor_id. apply id_disp.
  - simpl; intros x y z f g xx yy zz ff gg.
    refine (transportb _ _ _).
    apply functor_comp. exact (ff ;; gg).    
Defined.

Definition reindex_disp_precat_data : disp_precat_data C'
  := (_ ,, reindex_disp_precat_id_comp).

Definition reindex_disp_precat_axioms : disp_precat_axioms C' reindex_disp_precat_data.
Proof.
  repeat apply tpair; cbn.
  - intros x y f xx yy ff. 
    eapply pathscomp0. apply maponpaths, compl_disp_transp.
    eapply pathscomp0. apply transport_b_f.
    eapply pathscomp0. apply maponpaths, id_left_disp.
    eapply pathscomp0. apply transport_f_b.
    eapply pathscomp0. Focus 2. apply @pathsinv0, (functtransportb (# F)).
    unfold transportb; apply maponpaths_2, homset_property.
  - intros x y f xx yy ff. 
    eapply pathscomp0. apply maponpaths, compr_disp_transp.
    eapply pathscomp0. apply transport_b_f.
    eapply pathscomp0. apply maponpaths, id_right_disp.
    eapply pathscomp0. apply transport_f_b.
    eapply pathscomp0. Focus 2. apply @pathsinv0, (functtransportb (# F)).
    unfold transportb; apply maponpaths_2, homset_property.
  - intros x y z w f g h xx yy zz ww ff gg hh.
    eapply pathscomp0. apply maponpaths, compr_disp_transp.
    eapply pathscomp0. apply transport_b_f.
    eapply pathscomp0. apply maponpaths, assoc_disp.
    eapply pathscomp0. apply transport_f_b.
    apply pathsinv0.
    eapply pathscomp0. apply (functtransportb (# F)).
    eapply pathscomp0. apply transport_b_b.
    eapply pathscomp0. apply maponpaths, compl_disp_transp.
    eapply pathscomp0. apply transport_b_f.
    unfold transportb; apply maponpaths_2, homset_property.
  - intros; apply homsets_disp.
Qed.

Definition reindex_disp_precat : disp_precat C'
  := (_ ,, reindex_disp_precat_axioms).

End Reindexing.

(** ** Functors into displayed categories *)

(** Just like how context morphisms in a CwA can be built up out of terms, similarly, the basic building-block for functors into (total cats of) displayed precategories will be analogous to a term. 

We call it a _section_ (though we define it intrinsically, not as a section in a (bi)category), since it corresponds to a section of the forgetful functor. *)

Section Sections.

Definition section_disp_data {C} (D : disp_precat C) : Type
  := Σ (Fob : forall x:C, D x),
       (forall (x y:C) (f:x ⇒ y), Fob x ⇒[f] Fob y).

Definition section_disp_on_objects {C} {D : disp_precat C}
  (F : section_disp_data D) (x : C)
:= pr1 F x : D x.

Coercion section_disp_on_objects : section_disp_data >-> Funclass.

Definition section_disp_on_morphisms {C} {D : disp_precat C}
  (F : section_disp_data D) {x y : C} (f : x ⇒ y)
:= pr2 F _ _ f : F x ⇒[f] F y.

Notation "# F" := (section_disp_on_morphisms F)
  (at level 3) : mor_disp_scope.

Definition section_disp_axioms {C} {D : disp_precat C}
  (F : section_disp_data D) : Type
:= ((forall x:C, # F (identity x) = id_disp (F x))
  × (forall (x y z : C) (f : x ⇒ y) (g : y ⇒ z),
      # F (f ;; g)%mor = (# F f) ;; (# F g))).

Definition section_disp {C} (D : disp_precat C) : Type
  := total2 (@section_disp_axioms C D).

Definition section_disp_data_from_section_disp {C} {D : disp_precat C}
  (F : section_disp D) := pr1 F.

Coercion section_disp_data_from_section_disp
  : section_disp >-> section_disp_data.

Definition section_disp_id {C} {D : disp_precat C} (F : section_disp D)
  := pr1 (pr2 F).

Definition section_disp_comp {C} {D : disp_precat C} (F : section_disp D)
  := pr2 (pr2 F).

End Sections.

(** With sections defined, we can now define _lifts_ to a displayed precategory of a functor into the base. *)
Section Functor_Lifting.

Notation "# F" := (section_disp_on_morphisms F)
  (at level 3) : mor_disp_scope.

Definition functor_lifting
  {C C' : Precategory} (D : disp_precat C) (F : functor C' C) 
  := section_disp (reindex_disp_precat F D).

Identity Coercion section_from_functor_lifting
  : functor_lifting >-> section_disp.

(** Note: perhaps it would be better to define [functor_lifting] directly? 
  Reindexed displayed-precats are a bit confusing to work in, since a term like [id_disp xx] is ambiguous: it can mean both the identity in the original displayed category, or the identity in the reindexing, which is nearly but not quite the same.  This shows up already in the proofs of [lifted_functor_axioms] below. *)

Definition lifted_functor_data {C C' : Precategory} {D : disp_precat C}
  {F : functor C' C} (FF : functor_lifting D F)
  : functor_data C' (total_precat D).
Proof.
  exists (fun x => (F x ,, FF x)). 
  intros x y f. exists (# F f)%mor. exact (# FF f).
Defined.

Definition lifted_functor_axioms {C C' : Precategory} {D : disp_precat C}
  {F : functor C' C} (FF : functor_lifting D F)
  : is_functor (lifted_functor_data FF).
Proof.
  split.
  - intros x. use total2_paths; simpl.
    apply functor_id.
    eapply pathscomp0. apply maponpaths, (section_disp_id FF).
    cbn. apply Utilities.transportfbinv.
  - intros x y z f g. use total2_paths; simpl.
    apply functor_comp.
    eapply pathscomp0. apply maponpaths, (section_disp_comp FF).
    cbn. apply Utilities.transportfbinv.
Qed.

Definition lifted_functor {C C' : Precategory} {D : disp_precat C}
  {F : functor C' C} (FF : functor_lifting D F)
  : functor C' (total_precat D)
:= (_ ,, lifted_functor_axioms FF).

End Functor_Lifting.

(** ** Functors over functors between bases *)

(** One could define these in terms of functor-liftings, as:

[[
Definition functor_over {C C' : Precategory} (F : functor C C')
    (D : disp_precat C) (D' : disp_precat C')
  := functor_lifting D' (functor_composite (pr1_precat D) F). 
]]

However, it seems like it may probably be cleaner to define these independently.

TODO: reassess this design decision after some experience using it! *)

Section Functor_Over.

Definition functor_over_data {C' C : precategory_data} (F : functor_data C' C)
  (D' : disp_precat_data C') (D : disp_precat_data C)
:= Σ (Fob : Π x, D' x -> D (F x)),
     Π x y (xx : D' x) (yy : D' y) (f : x ⇒ y),
       (xx ⇒[f] yy) -> (Fob _ xx ⇒[ # F f ] Fob _ yy).

Definition functor_over_on_objects {C' C : precategory_data} {F : functor_data C' C}
    {D' : disp_precat_data C'} {D : disp_precat_data C}
    (FF : functor_over_data F D' D) {x : C'} (xx : D' x)
  : D (F x)
:= pr1 FF x xx.

Coercion functor_over_on_objects : functor_over_data >-> Funclass.

(** Unfortunately, the coercion loses implicitness of the {x:C'} argument:
  we have to write [ FF _ xx ] instead of just [ FF xx ].

  If anyone knows a way to avoid this, we would be happy to hear it! *)

Definition functor_over_on_morphisms {C' C : precategory_data} {F : functor_data C' C}
    {D' : disp_precat_data C'} {D : disp_precat_data C}
    (FF : functor_over_data F D' D)
    {x y : C'} {xx : D' x} {yy} {f : x ⇒ y} (ff : xx ⇒[f] yy)
  : (FF _ xx) ⇒[ # F f ] (FF _ yy)
:= pr2 FF x y xx yy f ff.

Notation "# F" := (functor_over_on_morphisms F)
  (at level 3) : mor_disp_scope.

Definition functor_over_axioms {C' C : Precategory} {F : functor C' C}
  {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over_data F D' D)
:=  (Π x (xx : D' x),
      # FF (id_disp xx) = transportb _ (functor_id F x) (id_disp (FF _ xx)))
  × (Π x y z (xx : D' x) yy zz (f : x ⇒ y) (g : y ⇒ z)
        (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz),
      # FF (ff ;; gg)
      = transportb _ (functor_comp F _ _ _ f g) (# FF ff ;; # FF gg)).

Definition functor_over {C' C : Precategory} (F : functor C' C)
  (D' : disp_precat C') (D : disp_precat C)
:= Σ FF : functor_over_data F D' D, functor_over_axioms FF.

Definition functor_over_data_from_functor_over
    {C' C} {F} {D' : disp_precat C'} {D : disp_precat C}
    (FF : functor_over F D' D)
  : functor_over_data F D' D
:= pr1 FF.

Coercion functor_over_data_from_functor_over
  : functor_over >-> functor_over_data.

Definition functor_over_id {C' C} {F} {D' : disp_precat C'} {D : disp_precat C}
    (FF : functor_over F D' D)
    {x} (xx : D' x)
  : # FF (id_disp xx) = transportb _ (functor_id F x) (id_disp (FF _ xx))
:= pr1 (pr2 FF) x xx.

Definition functor_over_comp {C' C} {F} {D' : disp_precat C'} {D : disp_precat C}
    (FF : functor_over F D' D)
    {x y z} {xx : D' x} {yy} {zz} {f : x ⇒ y} {g : y ⇒ z}
    (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : # FF (ff ;; gg)
    = transportb _ (functor_comp F _ _ _ f g) (# FF ff ;; # FF gg)
:= pr2 (pr2 FF) _ _ _ _ _ _ _ _ ff gg.

(** variant access function *)
Definition functor_over_comp_var {C' C} {F} {D' : disp_precat C'} {D : disp_precat C}
    (FF : functor_over F D' D)
    {x y z} {xx : D' x} {yy} {zz} {f : x ⇒ y} {g : y ⇒ z}
    (ff : xx ⇒[f] yy) (gg : yy ⇒[g] zz)
  : transportf _ (functor_comp F _ _ _ f g) (# FF (ff ;; gg)) 
     = # FF ff ;; # FF gg.
Proof.
  apply Utilities.transportf_pathsinv0.
  apply pathsinv0, functor_over_comp.
Defined.

(** Useful transport lemma for [functor_over]. *)
Lemma functor_over_transportf {C' C : Precategory}
  {D' : disp_precat C'} {D : disp_precat C}
  (F : functor C' C) (FF : functor_over F D' D)
  (x' x : C') (f' f : x' ⇒ x) (p : f' = f)
  (xx' : D' x') (xx : D' x)
  (ff : xx' ⇒[ f' ] xx) 
  :
  # FF (transportf _ p ff)
  = 
  transportf _ (maponpaths (#F)%mor p) (#FF ff) .
Proof.
  induction p.
  apply idpath.
Defined.

(** ** Composite and identity functors. *)

Definition functor_over_composite_data
    {C C' C'' : Precategory} {D} {D'} {D''}
    {F : functor C C'} {F' : functor C' C''}
    (FF : functor_over F D D')
    (FF' : functor_over F' D' D'')
  : functor_over_data (functor_composite F F') D D''.
Proof.
  mkpair.
  + intros x xx. exact (FF' _ (FF _ xx)).
  + intros x y xx yy f ff. exact (# FF' (# FF ff)).
Defined.

Lemma functor_over_composite_axioms
    {C C' C'' : Precategory} {D} {D'} {D''}
    {F : functor C C'} {F' : functor C' C''}
    (FF : functor_over F D D')
    (FF' : functor_over F' D' D'')
: functor_over_axioms (functor_over_composite_data FF FF').
Proof.
  split; simpl.
  + intros x xx.
    etrans. apply maponpaths. apply functor_over_id.
    etrans. apply functor_over_transportf.
    etrans. apply maponpaths. apply functor_over_id.
    etrans. apply transport_f_f.
    apply transportf_ext, homset_property.
  + intros.
    etrans. apply maponpaths. apply functor_over_comp.
    etrans. apply functor_over_transportf.
    etrans. apply maponpaths. apply functor_over_comp.
    etrans. apply transport_f_f.
    apply transportf_ext, homset_property.
Qed.

Definition functor_over_composite
    {C C' C'' : Precategory} {D} {D'} {D''}
    {F : functor C C'} {F' : functor C' C''}
    (FF : functor_over F D D')
    (FF' : functor_over F' D' D'')
  : functor_over (functor_composite F F') D D''.
Proof.
  mkpair.
  - apply (functor_over_composite_data FF FF').
  - apply functor_over_composite_axioms.
Defined.

Definition functor_over_identity
    {C : Precategory} (D : disp_precat C)
  : functor_over (functor_identity _ ) D D.
Proof.
  mkpair.
  - mkpair. 
    + intros; assumption.
    + intros; assumption.
  - split; simpl.      
    + intros; apply idpath.
    + intros; apply idpath.
Defined.

(** ** Action of functors on isos. *)
Section Functors_on_isos.

(* TODO: functor_on_inv_from_iso should have implicit arguments *)

Lemma functor_over_on_iso_disp_aux1 {C C'} {F} 
    {D : disp_precat C} {D' : disp_precat C'}
    (FF : functor_over F D D')
    {x y} {xx : D x} {yy} {f : iso x y} 
    (ff : xx ⇒[f] yy)
    (Hff : is_iso_disp f ff)
  : transportf _ (functor_on_inv_from_iso _ _ F _ _ f)
      (# FF (inv_mor_disp_from_iso Hff))
    ;; # FF ff 
  = transportb _ (iso_after_iso_inv _) (id_disp _).
Proof.
  etrans. apply mor_disp_transportf_postwhisker.
  etrans. apply maponpaths, @pathsinv0, functor_over_comp_var.
  etrans. apply transport_f_f.
  etrans. apply maponpaths, maponpaths, iso_disp_after_inv_mor.
  etrans. apply maponpaths, functor_over_transportf.
  etrans. apply transport_f_f.
  etrans. apply maponpaths, functor_over_id.
  etrans. apply transport_f_b.
  unfold transportb. apply maponpaths_2, homset_property.
Qed.

Lemma functor_over_on_iso_disp_aux2 {C C'} {F} 
    {D : disp_precat C} {D' : disp_precat C'}
    (FF : functor_over F D D')
    {x y} {xx : D x} {yy} {f : iso x y} 
    (ff : xx ⇒[f] yy)
    (Hff : is_iso_disp f ff)
  : # FF ff
    ;; transportf _ (functor_on_inv_from_iso _ _ F _ _ f)
         (# FF (inv_mor_disp_from_iso Hff))
  =
    transportb _ (iso_inv_after_iso (functor_on_iso _ _)) (id_disp (FF x xx)).
Proof.
  etrans. apply mor_disp_transportf_prewhisker.
  etrans. apply maponpaths, @pathsinv0, functor_over_comp_var.
  etrans. apply transport_f_f.
  etrans. apply maponpaths, maponpaths, inv_mor_after_iso_disp.
  etrans. apply maponpaths, functor_over_transportf.
  etrans. apply transport_f_f.
  etrans. apply maponpaths, functor_over_id.
  etrans. apply transport_f_f.
  unfold transportb. apply maponpaths_2, homset_property.
Qed.

(** Let's see how [functor_over]s behave on [iso_disp]s *)
(** TODO: consider naming *)
Undelimit Scope transport.
Definition functor_over_on_is_iso_disp {C C'} {F} 
    {D : disp_precat C} {D' : disp_precat C'}
    (FF : functor_over F D D')
    {x y} {xx : D x} {yy} {f : iso x y} 
    {ff : xx ⇒[f] yy} (Hff : is_iso_disp f ff)
    : is_iso_disp (functor_on_iso F f) (# FF ff).
Proof.
  exists (transportf _ (functor_on_inv_from_iso _ _ F _ _ f)
           (# FF (inv_mor_disp_from_iso Hff))); split. 
  - apply functor_over_on_iso_disp_aux1.
  - apply functor_over_on_iso_disp_aux2.
Defined.

Definition functor_over_on_iso_disp {C C'} {F} 
    {D : disp_precat C} {D' : disp_precat C'}
    (FF : functor_over F D D')
    {x y} {xx : D x} {yy} {f : iso x y} 
    (ff : iso_disp f xx yy)
  : iso_disp (functor_on_iso F f) (FF _ xx) (FF _ yy)
:= (_ ,, functor_over_on_is_iso_disp _ ff).

End Functors_on_isos.


(** ** Properties of functors *)

Section Functor_Properties.

Definition functor_over_ff {C C'} {F}
  {D : disp_precat C} {D' : disp_precat C'} (FF : functor_over F D D')
:=
  Π {x y} {xx : D x} {yy : D y} {f : x ⇒ y},
    isweq (fun ff : xx ⇒[f] yy => # FF ff).

Section ff_reflects_isos.

Context {C C' : Precategory}
        {F : functor C C'}
        {D : disp_precat C}
        {D' : disp_precat C'}
        (FF : functor_over F D D')
        (FF_ff : functor_over_ff FF).

Definition functor_over_ff_weq {x y} xx yy f
  := weqpair _ (FF_ff x y xx yy f).
Definition functor_over_ff_inv {x y} {xx} {yy} {f : x ⇒ y}  
  := invmap (functor_over_ff_weq xx yy f).

(* TODO: add a general version [functor_over_ff_inv_transportf], where the transportf on the LHS is arbitrary. *) 
Lemma functor_over_ff_inv_transportf
    {x y : C} {f f' : x ⇒ y} (e : f = f')
    {xx : D x} {yy : D y} (ff : FF _ xx ⇒[#F f] FF _ yy)
  : functor_over_ff_inv (transportf _ (maponpaths (# F )%mor e) ff) 
    = 
    transportf _ e (functor_over_ff_inv ff).
Proof.
  induction e.
  apply idpath.
Qed.

(* TODO: move the transport to the RHS. *)
Lemma functor_over_ff_inv_identity {x : C} (xx : D x)
  : functor_over_ff_inv (transportb _ (functor_id F _ ) (id_disp (FF _ xx)))
  = id_disp xx.
Proof.
  apply invmap_eq. 
  apply pathsinv0.
  apply (functor_over_id FF).
Qed.

(* TODO: move the transport to the RHS. *)
Lemma functor_over_ff_inv_compose {x y z : C} {f : x ⇒ y} {g : y ⇒ z}
    {xx} {yy} {zz}
    (ff : FF _ xx ⇒[#F f] FF _ yy) (gg : FF _ yy ⇒[#F g] FF _ zz)
  : functor_over_ff_inv (transportb _ (functor_comp F _ _ _ _ _ ) (ff ;; gg)) 
  = functor_over_ff_inv ff ;; functor_over_ff_inv gg.
Proof.
  apply invmap_eq. cbn.
  apply pathsinv0.
  etrans. apply (functor_over_comp FF).
  apply maponpaths.
  etrans. apply maponpaths. exact (homotweqinvweq _ _).
  apply maponpaths_2. exact (homotweqinvweq _ _).
Qed.

Definition functor_over_ff_reflects_isos 
  {x y} {xx : D x} {yy : D y} {f : iso x y}
  (ff : xx ⇒[f] yy) (isiso: is_iso_disp (functor_on_iso F f) (# FF ff)) 
  : is_iso_disp _ ff.
Proof.
  set (FFffinv := inv_mor_disp_from_iso isiso). 
  set (FFffinv' := transportb _ (functor_on_inv_from_iso _ _ _ _ _ _ ) FFffinv).
  set (ffinv := functor_over_ff_inv FFffinv').
  exists ffinv.
  split.
  - unfold ffinv. unfold FFffinv'.
    admit.
  - admit.
Abort.

End ff_reflects_isos.

(** Given a base functor [F : C —> C'] and a displayed functor [FF : D' -> D] over it, there are two different “essential surjectivity” conditions one can put on [FF].

Given [c : C] and [d : D' (F c)], one can ask for a lift of [d] either in [D c] itself, or more generally in some fibre [D c'] with [c'] isomorphic to [c].

The second version is better-behaved in general; but the stricter first version is equivalent when [D] is an isofibration, and is simpler to work with.  So we call the second version “essentially split surjective”, [functor_over_ess_split_surj], and the first “displayed ess. split surj.”, [functor_over_disp_ess_split_surj].
*)

Definition functor_over_ess_split_surj {C' C} {F}
  {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over F D D')
  : UU
:=
  Π {x} {xx : D' (F x)},
    Σ y : C, 
    Σ i : iso y x, 
    Σ yy : D y,
      iso_disp (functor_on_iso F i) (FF _ yy) xx.

Definition functor_over_disp_ess_split_surj {C' C} {F}
  {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over F D D')
  : UU
:= 
  Π {x} {xx : D' (F x)},
    Σ (yy : D x), 
      iso_disp (identity_iso _) (FF _ yy) xx.

(* TODO: add access functions for these. *)

End Functor_Properties.

(** ** Total functors of displayed functors*)
Section Total_Functors.

Definition total_functor_data {C' C} {F}
    {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over F D' D)
  : functor_data (total_precat D') (total_precat D).
Proof.
  mkpair.
  - intros xx. exists (F (pr1 xx)). exact (FF _ (pr2 xx)).
  - intros xx yy ff. exists (# F (pr1 ff))%mor. exact (# FF (pr2 ff)).
Defined.

Definition total_functor_axioms {C' C} {F}
    {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over F D' D)
  : is_functor (total_functor_data FF).
Proof.
  split.
  - intros xx; use total2_paths.
      apply functor_id.
    etrans. apply maponpaths, functor_over_id.
    apply Utilities.transportfbinv.
  - intros xx yy zz ff gg; use total2_paths; simpl.
      apply functor_comp.
    etrans. apply maponpaths, functor_over_comp.
    apply Utilities.transportfbinv.
Qed.

Definition total_functor {C' C} {F}
    {D' : disp_precat C'} {D : disp_precat C} (FF : functor_over F D' D)
  : functor (total_precat D') (total_precat D)
:= (total_functor_data FF,, total_functor_axioms FF).

End Total_Functors.

End Functor_Over.

(* Redeclare notations globally: *)

Notation "# F" := (functor_over_on_morphisms F)
  (at level 3) : mor_disp_scope.

(** ** Natural Transformations *)
Section Nat_Trans_Over.

Definition nat_trans_over_data
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  (a : forall x, F' x ⇒ F x)
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  (R' : functor_over_data F' D' D)
  (R : functor_over_data F D' D) :=
forall (x : C')  (xx : D' x), 
      R' x  xx ⇒[ a x ] R x xx .
(*
Check @nat_trans_ax.

@nat_trans_ax
     : Π (C C' : precategory_data) (F F' : functor_data C C')
       (a : nat_trans F F') (x x' : C) (f : x ⇒ x'),
       (# F f ;; a x')%mor = (a x ;; # F' f)%mor
*)

Definition nat_trans_over_axioms
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  {a : nat_trans F' F}
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b : nat_trans_over_data a R' R) : UU
 := 
   forall (x' x : C') (f : x' ⇒ x)
          (xx' : D' x') (xx : D' x) 
          (ff : xx' ⇒[ f ] xx), 
     # R'  ff ;; b _ xx = 
     transportb _ (nat_trans_ax a _ _ f ) (b _ xx' ;; # R ff).

Lemma isaprop_nat_trans_over_axioms
  {C' C : Precategory} 
  {F' F : functor_data C' C}
  (a : nat_trans F' F)
  {D' : disp_precat_data C'}
  {D : disp_precat C}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b : nat_trans_over_data a R' R) 
  : 
    isaprop (nat_trans_over_axioms b).
Proof.
  repeat (apply impred; intro).
  apply homsets_disp.
Qed.

Definition nat_trans_over
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  (a : nat_trans F' F)
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  (R' : functor_over_data F' D' D)
  (R : functor_over_data F D' D) : UU :=
  Σ b : nat_trans_over_data a R' R,
    nat_trans_over_axioms b.

Definition nat_trans_over_pr1 
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  {a : nat_trans F' F}
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b : nat_trans_over a R' R) 
  {x : C'}  (xx : D' x):
    R' x  xx ⇒[ a x ] R x xx
  := pr1 b x xx.

Coercion nat_trans_over_pr1 : nat_trans_over >-> Funclass.

Definition nat_trans_over_ax
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  {a : nat_trans F' F}
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b : nat_trans_over a R' R)
  {x' x : C'} 
  {f : x' ⇒ x}
  {xx' : D' x'} 
  {xx : D' x}
  (ff : xx' ⇒[ f ] xx):
  # R'  ff ;; b _ xx = 
  transportb _ (nat_trans_ax a _ _ f ) (b _ xx' ;; # R ff)
  := 
  pr2 b _ _ f _ _ ff.

Lemma nat_trans_over_ax_var
  {C' C : precategory_data} 
  {F' F : functor_data C' C}
  {a : nat_trans F' F}
  {D' : disp_precat_data C'}
  {D : disp_precat_data C}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b : nat_trans_over a R' R)
  {x' x : C'} 
  {f : x' ⇒ x}
  {xx' : D' x'} 
  {xx : D' x}
  (ff : xx' ⇒[ f ] xx):
  b _ xx' ;; # R ff =
  transportf _ (nat_trans_ax a _ _ f) (# R'  ff ;; b _ xx).
Proof.
  apply pathsinv0, Utilities.transportf_pathsinv0.
  apply pathsinv0, nat_trans_over_ax.
Defined.


(** identity nat_trans_over *)

Definition nat_trans_over_id
  {C' C : Precategory} 
  {F': functor_data C' C}
  {D' : disp_precat_data C'}
  {D : disp_precat C}
  (R' : functor_over_data F' D' D)
  : nat_trans_over (nat_trans_id F') R' R'.
Proof.
  mkpair.
  - intros x xx.
    apply id_disp.
  - abstract (
    intros x' x f xx' xx ff;
    etrans; [ apply id_right_disp |];
    apply transportf_comp_lemma;
    apply pathsinv0;
    etrans; [apply id_left_disp |];
    apply transportf_ext;
    apply (pr2 C) ).
Defined.    
    

(** composition of nat_trans_over *)



Definition nat_trans_over_comp
  {C' C : Precategory} 
  {F'' F' F : functor_data C' C}
  {a' : nat_trans F'' F'}
  {a : nat_trans F' F}
  {D' : disp_precat_data C'}
  {D : disp_precat C}
  {R'' : functor_over_data F'' D' D}
  {R' : functor_over_data F' D' D}
  {R : functor_over_data F D' D}
  (b' : nat_trans_over a' R'' R')
  (b : nat_trans_over a R' R)
  : nat_trans_over (nat_trans_comp _ _ _ a' a) R'' R.
Proof.
  mkpair.
  - intros x xx.
    apply (comp_disp (b' _ _ )  (b _ _ )).
  - abstract ( 
    intros x' x f xx' xx ff;
    etrans; [ apply assoc_disp |];
    apply transportf_comp_lemma;
    apply Utilities.transportf_pathsinv0; apply pathsinv0;
    rewrite (nat_trans_over_ax b');
    etrans; [ apply compl_disp_transp |];
    apply transportf_comp_lemma;
    apply pathsinv0;
    etrans; [ apply assoc_disp_var |];
    apply pathsinv0;
    apply transportf_comp_lemma;
    apply pathsinv0;
    rewrite (nat_trans_over_ax_var b);
    rewrite mor_disp_transportf_prewhisker;
    apply transportf_comp_lemma;
    apply pathsinv0;
    etrans; [ apply assoc_disp_var |];
    apply transportf_comp_lemma;
    apply transportf_comp_lemma_hset;
     [ apply (pr2 C) | apply idpath]
   ).
Defined.

End Nat_Trans_Over.

(** * Fibrations *)

(** Fibratons, opfibrations, and isofibrations are all displayed categories with extra lifting conditions. *)

(* TODO: flesh out this section; probably break it out into its own file. *)
Section Fibrations.

(** whenever you have an iso φ : c =~ c' in C, and an object d in D c,
there’s some object d' in D c', and an iso φbar : d =~ d' over φ
*)

Definition isofibration {C : Precategory} (D : disp_precat C) : UU
  := 
  forall (c c' : C) (i : iso c c') (d : D c),
          Σ d' : D c', iso_disp i d d'.


End Fibrations.

(** some TODOs for the displayed-cats library:

- add lemmas connecting with products of precats (as required for displayed bicats)
- add more applications of the displayed arrow category: slices; equalisers, inserters; hence groups etc.

*)