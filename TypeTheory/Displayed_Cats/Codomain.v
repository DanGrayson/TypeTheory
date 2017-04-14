
(** * Examples 

A typical use for displayed categories is for constructing categories of structured objects, over a given (specific or general) category. We give a few examples here:

- arrow precategories
- objects with N-actions
- elements, over hSet

*)

Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.limits.pullbacks.

Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.UnicodeNotations.

Require Import TypeTheory.Displayed_Cats.Auxiliary.
Require Import TypeTheory.Displayed_Cats.Core.
Require Import TypeTheory.Displayed_Cats.Fibrations.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

(** ** The displayed codomain  

The total category associated to this displayed category is going to be 
isomorphic to the arrow category, but it won't be the same:
the components of the objects and morphisms will be arranged differently

*)

(* TODO: perhaps rename [slice_disp], and make [C] implicit? *)
Section Codomain_Disp.

Context (C:Precategory).

Definition cod_disp_ob_mor : disp_precat_ob_mor C.
Proof.
  exists (fun x : C => ∑ y, y --> x).
  simpl; intros x y xx yy f. 
    exact (∑ ff : pr1 xx --> pr1 yy, ff ;; pr2 yy = pr2 xx ;; f).
Defined.

Definition cod_id_comp : disp_precat_id_comp _ cod_disp_ob_mor.
Proof.
  split.
  - simpl; intros.
    exists (identity _ ).
    abstract (
        etrans; [apply id_left |];
        apply pathsinv0, id_right ).
  - simpl; intros x y z f g xx yy zz ff gg.
    exists (pr1 ff ;; pr1 gg).
    abstract ( 
        apply pathsinv0;
        etrans; [apply assoc |];
        etrans; [apply maponpaths_2, (! (pr2 ff)) |];
        etrans; [eapply pathsinv0, assoc |];
        etrans; [apply maponpaths, (! (pr2 gg))|];
        apply assoc).
Defined.

Definition cod_disp_data : disp_precat_data _
  := (cod_disp_ob_mor ,, cod_id_comp).

Lemma cod_disp_axioms : disp_precat_axioms C cod_disp_data.
Proof.
  repeat apply tpair; intros; try apply homset_property.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply id_left.
    destruct ff as [ff H]. 
    apply pathsinv0.
    etrans. refine (pr1_transportf (C⟦x,y⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply id_right.
    destruct ff as [ff H]. 
    apply pathsinv0.
    etrans. refine (pr1_transportf (C⟦x,y⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply assoc.
    destruct ff as [ff H]. 
    apply pathsinv0.
    etrans. unfold mor_disp.
    refine (pr1_transportf (C⟦x,w⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply (isofhleveltotal2 2).
    + apply homset_property.
    + intro. apply isasetaprop. apply homset_property.
Qed.

Definition cod_disp : disp_precat C
  := (cod_disp_data ,, cod_disp_axioms).

End Codomain_Disp.

Section Pullbacks_Cartesian.

Context {C:Precategory}.

Definition isPullback_cartesian_in_cod_disp
    { Γ Γ' : C } {f : Γ' --> Γ}
    {p : cod_disp _ Γ} {p' : cod_disp _ Γ'} (ff : p' -->[f] p)
  : (isPullback _ _ _ _ (pr2 ff)) -> is_cartesian ff.
Proof.
  intros Hpb Δ g q hh.
  eapply iscontrweqf.
  Focus 2. { 
    use Hpb.
    + exact (pr1 q).
    + exact (pr1 hh).
    + simpl in q. refine (pr2 q ;; g).
    + etrans. apply (pr2 hh). apply assoc.
  } Unfocus.
  eapply weqcomp.
  Focus 2. apply weqtotal2asstol.
  apply weq_subtypes_iff.
  - intro. apply isapropdirprod; apply homset_property.
  - intro. apply (isofhleveltotal2 1). 
    + apply homset_property.
    + intros. apply homsets_disp.
  - intros gg; split; intros H.
    + exists (pr2 H).
      apply subtypeEquality.
        intro; apply homset_property.
      exact (pr1 H).
    + split.
      * exact (maponpaths pr1 (pr2 H)).
      * exact (pr1 H).
Qed.

Definition cartesian_isPullback_in_cod_disp
    { Γ Γ' : C } {f : Γ' --> Γ}
    {p : cod_disp _ Γ} {p' : cod_disp _ Γ'} (ff : p' -->[f] p)
  : (isPullback _ _ _ _ (pr2 ff)) <- is_cartesian ff.
Proof.
  intros cf c h k H.
  destruct p as [a x].
  destruct p' as [b y].
  destruct ff as [H1 H2].
  unfold is_cartesian in cf.
  simpl in *.
  eapply iscontrweqf.
  Focus 2. { 
    use cf.
    + exact Γ'.
    + exact (identity _ ).
    + exists c. exact k.
    + cbn. exists h.
      etrans. apply H. apply maponpaths. apply (! id_left _ ).
  } Unfocus.
  eapply weqcomp.
  apply weqtotal2asstor.
  apply weq_subtypes_iff.

  - intro. apply (isofhleveltotal2 1). 
    + apply homset_property.
    + intros. 
      match goal with |[|- isofhlevel 1 (?x = _ )] => 
                       set (X := x) end.
      set (XR := @homsets_disp _ (cod_disp C )). 
      specialize (XR _ _ _ _ _ X).
      apply XR.
  - cbn. intro. apply isapropdirprod; apply homset_property.
  - intros gg; split; intros HRR.
    + split.
      * exact (maponpaths pr1 (pr2 HRR)).
      * etrans. apply (pr1 HRR). apply id_right.
    + mkpair. 
      * rewrite id_right.
        exact (pr2 HRR).
      * apply subtypeEquality.
        intro; apply homset_property.
      exact (pr1 HRR).
Qed.


Definition cartesian_iff_isPullback
    { Γ Γ' : C } {f : Γ' --> Γ}
    {p : cod_disp _ Γ} {p' : cod_disp _ Γ'} (ff : p' -->[f] p)
  : (isPullback _ _ _ _ (pr2 ff)) <-> is_cartesian ff.
Proof.
  split.
  - apply isPullback_cartesian_in_cod_disp.
  - apply cartesian_isPullback_in_cod_disp.
Defined.

End Pullbacks_Cartesian.


