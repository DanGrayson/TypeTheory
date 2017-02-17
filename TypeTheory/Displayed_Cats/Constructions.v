
(** Some important constructions on displayed categories

Partial contents:

- Direct products of displayed precategories (and their projections)
  - [dirprod_precat D1 D2]
  - [dirprodpr1_functor], [dirprodpr2_functor]
- Sigmas of displayed precategories
- Displayed functor precat
- Fiber precats
*)

Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.

Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.UnicodeNotations.
Require Import TypeTheory.Displayed_Cats.Auxiliary.
Require Import TypeTheory.Displayed_Cats.Core.

Local Open Scope mor_disp_scope.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

Section Auxiliary.

(* TODO: perhaps upstream; consider name *)
Lemma total2_reassoc_paths {A} {B : A → UU} {C : (∑ a, B a) -> UU}
    (BC : A -> UU := fun a => ∑ b, C (a,,b))
    {a1 a2 : A} (bc1 : BC a1) (bc2 : BC a2)
    (ea : a1 = a2)
    (eb : transportf _ ea (pr1 bc1) = pr1 bc2)
    (ec : transportf C (two_arg_paths_f (*was total2_paths2*) ea eb) (pr2 bc1) = pr2 bc2)
  : transportf _ ea bc1 = bc2.
Proof.
  destruct ea, bc1 as [b1 c1], bc2 as [b2 c2].
  cbn in *; destruct eb, ec.
  apply idpath.
Defined.

(* TODO: as for non-primed version above *)
Lemma total2_reassoc_paths' {A} {B : A → UU} {C : (∑ a, B a) -> UU}
    (BC : A -> UU := fun a => ∑ b, C (a,,b))
    {a1 a2 : A} (bc1 : BC a1) (bc2 : BC a2)
    (ea : a1 = a2)
    (eb : pr1 bc1 = transportb _ ea (pr1 bc2))
    (ec : pr2 bc1 = transportb C (total2_paths2_b ea eb) (pr2 bc2))
  : bc1 = transportb _ ea bc2.
Proof.
  destruct ea, bc1 as [b1 c1], bc2 as [b2 c2].
  cbn in eb; destruct eb; cbn in ec; destruct ec.
  apply idpath.
Defined.

Lemma transportf_pathsinv0_var :
∏ {X : UU} {P : X → UU} {x y : X} {p : x = y} {u : P x} 
{v : P y}, transportf P p u = v → transportf P (!p) v = u.
Proof.
  intros. induction p. apply (!X0).
Defined.

End Auxiliary.


(** * Products of displayed (pre)categories 

We directly define direct products of displayed categories over a base.

An alternative would be to define the direct product as the [sigma_disp_precat] of the pullback to either factor.  *)
Section Dirprod.

Context {C : Precategory} (D1 D2 : disp_precat C).

Definition dirprod_disp_precat_ob_mor : disp_precat_ob_mor C.
Proof.
  exists (fun c => (D1 c × D2 c)).
  intros x y xx yy f.
  exact (pr1 xx -->[f] pr1 yy × pr2 xx -->[f] pr2 yy).
Defined.

Definition dirprod_disp_precat_id_comp
  : disp_precat_id_comp _ dirprod_disp_precat_ob_mor.
Proof.
  apply tpair.
  - intros x xx. exact (id_disp _,, id_disp _).
  - intros x y z f g xx yy zz ff gg.
    exact ((pr1 ff ;; pr1 gg),, (pr2 ff ;; pr2 gg)).
Defined.

Definition dirprod_disp_precat_data : disp_precat_data C
  := (_ ,, dirprod_disp_precat_id_comp).

Definition dirprod_disp_precat_axioms
  : disp_precat_axioms _ dirprod_disp_precat_data.
Proof.
  repeat apply tpair.
  - intros. apply dirprod_paths; refine (id_left_disp @ !_).
    + refine (pr1_transportf _ _ _ _ _ _ _).
    + apply pr2_transportf.
  - intros. apply dirprod_paths; refine (id_right_disp @ !_).
    + refine (pr1_transportf _ _ _ _ _ _ _).
    + apply pr2_transportf.
  - intros. apply dirprod_paths; refine (assoc_disp @ !_).
    + refine (pr1_transportf _ _ _ _ _ _ _).
    + apply pr2_transportf.
  - intros. apply isaset_dirprod; apply homsets_disp.
Qed.

Definition dirprod_disp_precat : disp_precat C
  := (_ ,, dirprod_disp_precat_axioms).

Definition dirprodpr1_disp_functor_data
  : functor_over_data (functor_identity C) dirprod_disp_precat (D1).
Proof.
  mkpair.
  - intros x xx; exact (pr1 xx).
  - intros x y xx yy f ff; exact (pr1 ff).
Defined.

Definition dirprodpr1_disp_functor_axioms
  : functor_over_axioms dirprodpr1_disp_functor_data.
Proof.
  split. 
  - intros; apply idpath.
  - intros; apply idpath.
Qed.

Definition dirprodpr1_disp_functor
  : functor_over (functor_identity C) dirprod_disp_precat (D1)
:= (dirprodpr1_disp_functor_data,, dirprodpr1_disp_functor_axioms).


Definition dirprodpr2_disp_functor_data
  : functor_over_data (functor_identity C) dirprod_disp_precat (D2).
Proof.
  mkpair.
  - intros x xx; exact (pr2 xx).
  - intros x y xx yy f ff; exact (pr2 ff).
Defined.

Definition dirprodpr2_disp_functor_axioms
  : functor_over_axioms dirprodpr2_disp_functor_data.
Proof.
  split. 
  - intros; apply idpath.
  - intros; apply idpath.
Qed.

Definition dirprodpr2_disp_functor
  : functor_over (functor_identity C) dirprod_disp_precat (D2)
:= (dirprodpr2_disp_functor_data,, dirprodpr2_disp_functor_axioms).

End Dirprod.

Notation "D1 × D2" := (dirprod_disp_precat D1 D2) : disp_precat_scope.
Delimit Scope disp_precat_scope with disp_precat.
Bind Scope disp_precat_scope with disp_precat.

(** * Sigmas of displayed (pre)categories *)
Section Sigma.

Context {C : Precategory}
        {D : disp_precat C}
        (E : disp_precat (total_precat D)).

Definition sigma_disp_precat_ob_mor : disp_precat_ob_mor C.
Proof.
  exists (fun c => ∑ (d : D c), (E (c,,d))).
  intros x y xx yy f.
  exact (∑ (fD : pr1 xx -->[f] pr1 yy), 
                (pr2 xx -->[f,,fD] pr2 yy)).
Defined.

Definition sigma_disp_precat_id_comp
  : disp_precat_id_comp _ sigma_disp_precat_ob_mor.
Proof.
  apply tpair.
  - intros x xx.
    exists (id_disp _). exact (id_disp (pr2 xx)).
  - intros x y z f g xx yy zz ff gg.
    exists (pr1 ff ;; pr1 gg). exact (pr2 ff ;; pr2 gg).
Defined.

Definition sigma_disp_precat_data : disp_precat_data C
  := (_ ,, sigma_disp_precat_id_comp).


Definition sigma_disp_precat_axioms
  : disp_precat_axioms _ sigma_disp_precat_data.
Proof.
  repeat apply tpair.
  - intros. use total2_reassoc_paths'.
    + apply id_left_disp.
    + etrans. exact (@id_left_disp _ _ _ _ _ _ _ (pr2 ff)).
      apply maponpaths_2, homset_property.
  - intros. use total2_reassoc_paths'.
    + apply id_right_disp.
    + etrans. exact (@id_right_disp _ _ _ _ _ _ _ (pr2 ff)).
      apply maponpaths_2, homset_property.
  - intros. use total2_reassoc_paths'.
    + apply assoc_disp.
    + etrans. 
        exact (@assoc_disp _ _
                 _ _ _ _  _ _ _ 
                 _ _ _ _  (pr2 ff) (pr2 gg) (pr2 hh)).
      apply maponpaths_2, homset_property.
  - intros. apply isaset_total2; intros; apply homsets_disp.
Qed.

Definition sigma_disp_precat : disp_precat C
  := (_ ,, sigma_disp_precat_axioms).

Definition sigmapr1_disp_functor_data
  : functor_over_data (functor_identity C) sigma_disp_precat D.
Proof.
  mkpair.
  - intros x xx; exact (pr1 xx).
  - intros x y xx yy f ff; exact (pr1 ff).
Defined.

Definition sigmapr1_disp_functor_axioms
  : functor_over_axioms sigmapr1_disp_functor_data.
Proof.
  split. 
  - intros; apply idpath.
  - intros; apply idpath.
Qed.

Definition sigmapr1_disp_functor
  : functor_over (functor_identity C) sigma_disp_precat D
:= (sigmapr1_disp_functor_data,, sigmapr1_disp_functor_axioms).

(* TODO: complete [sigmapr2_disp]; will be a [functor_lifting], not a [functor_over]. *)

(** ** Transport and isomorphism lemmas *)

Lemma pr1_transportf_sigma_disp {x y : C} {f f' : x --> y} (e : f = f')
    {xxx : sigma_disp_precat x} {yyy} (fff : xxx -->[f] yyy)
  : pr1 (transportf _ e fff) = transportf _ e (pr1 fff).
Proof.
  destruct e; apply idpath.
Qed.

Lemma pr2_transportf_sigma_disp {x y : C} {f f' : x --> y} (e : f = f')
    {xxx : sigma_disp_precat x} {yyy} (fff : xxx -->[f] yyy)
  : pr2 (transportf _ e fff)
  = transportf (fun ff => pr2 xxx -->[ff] _ ) (two_arg_paths_f (*total2_paths2*) e (! pr1_transportf_sigma_disp e fff))
      (pr2 fff).
Proof.
  destruct e. apply pathsinv0.
  etrans. apply maponpaths_2, maponpaths, maponpaths. 
  apply (homsets_disp _ _ _ (idpath _)).
  apply idpath.
Qed.


(** ** Univalence *)

Local Open Scope hide_transport_scope.

Definition is_iso_sigma_disp_aux1
    {x y} {xxx : sigma_disp_precat x} {yyy : sigma_disp_precat y}
    {f : iso x y} (fff : xxx -->[f] yyy) 
    (ii : is_iso_disp f (pr1 fff))
    (ffi := (_,, ii) : iso_disp f (pr1 xxx) (pr1 yyy))
    (iii : is_iso_disp (@total_iso _ _ (_,,_) (_,,_) f ffi) (pr2 fff))
  : yyy -->[inv_from_iso f] xxx.
Proof.
  exists (inv_mor_disp_from_iso ii).
  set (ggg := inv_mor_disp_from_iso iii).
  exact (transportf _ (inv_mor_total_iso _ _ _) ggg).
Defined.

Lemma is_iso_sigma_disp_aux2
    {x y} {xxx : sigma_disp_precat x} {yyy : sigma_disp_precat y}
    {f : iso x y} (fff : xxx -->[f] yyy) 
    (ii : is_iso_disp f (pr1 fff))
    (ffi := (_,, ii) : iso_disp f (pr1 xxx) (pr1 yyy))
    (iii : is_iso_disp (@total_iso _ _ (_,,_) (_,,_) f ffi) (pr2 fff))
  :   (is_iso_sigma_disp_aux1 fff ii iii) ;; fff
    = transportb _ (iso_after_iso_inv f) (id_disp yyy)
  ×
      fff ;; (is_iso_sigma_disp_aux1 fff ii iii)
    = transportb _ (iso_inv_after_iso f) (id_disp xxx).
Proof.
  split.
  - use total2_paths_f.
    + abstract ( etrans; 
        [ apply iso_disp_after_inv_mor
        | apply pathsinv0, pr1_transportf_sigma_disp]).
    + etrans. Focus 2. apply @pathsinv0, pr2_transportf_sigma_disp.
      etrans. apply maponpaths.
        refine (mor_disp_transportf_postwhisker
          (@inv_mor_total_iso _ _ (_,,_) (_,,_) f ffi) _ (pr2 fff)).
      etrans. apply functtransportf. 
      etrans. apply transport_f_f.
      etrans. eapply transportf_bind.
        apply (iso_disp_after_inv_mor iii).
      apply maponpaths_2, (@homset_property (total_precat D)).
  - use total2_paths_f; cbn.
    + abstract ( etrans;
        [ apply inv_mor_after_iso_disp
        | apply pathsinv0, pr1_transportf_sigma_disp ]).
    + etrans. Focus 2. apply @pathsinv0, pr2_transportf_sigma_disp.
      etrans. apply maponpaths.
      refine (mor_disp_transportf_prewhisker
        (@inv_mor_total_iso _ _ (_,,_) (_,,_) f ffi) (pr2 fff) _).
      etrans. apply functtransportf.
      etrans. apply transport_f_f.
      etrans. eapply transportf_bind.
        apply (inv_mor_after_iso_disp iii).
      apply maponpaths_2, (@homset_property (total_precat D)).
Time Qed. (* TODO: try to speed this up? *)

Lemma is_iso_sigma_disp
    {x y} {xxx : sigma_disp_precat x} {yyy : sigma_disp_precat y}
    {f : iso x y} (fff : xxx -->[f] yyy) 
    (ii : is_iso_disp f (pr1 fff))
    (ffi := (_,, ii) : iso_disp f (pr1 xxx) (pr1 yyy))
    (iii : is_iso_disp (@total_iso _ _ (_,,_) (_,,_) f ffi) (pr2 fff))
  : is_iso_disp f fff.
Proof.
  exists (is_iso_sigma_disp_aux1 fff ii iii).
  apply is_iso_sigma_disp_aux2.
Defined.

Definition sigma_disp_iso
    {x y} (xx : sigma_disp_precat x) (yy : sigma_disp_precat y)
    {f : iso x y} (ff : iso_disp f (pr1 xx) (pr1 yy))
    (fff : iso_disp (@total_iso _ _ (_,,_) (_,,_) f ff) (pr2 xx) (pr2 yy))
  : iso_disp f xx yy.
Proof.
  exists (pr1 ff,, pr1 fff). use is_iso_sigma_disp; cbn.
  - exact (pr2 ff).
  - exact (pr2 fff).
Defined.

Definition sigma_disp_iso_map
    {x y} (xx : sigma_disp_precat x) (yy : sigma_disp_precat y)
    (f : iso x y)
  : (∑ ff : iso_disp f (pr1 xx) (pr1 yy),
       iso_disp (@total_iso _ _ (_,,_) (_,,_) f ff) (pr2 xx) (pr2 yy))
  -> iso_disp f xx yy
:= fun ff => sigma_disp_iso _ _ (pr1 ff) (pr2 ff).

Lemma sigma_disp_iso_isweq
    {x y} (xx : sigma_disp_precat x) (yy : sigma_disp_precat y)
    (f : iso x y)
  : isweq (sigma_disp_iso_map xx yy f).
Proof.
Abort.

(*
Definition sigma_disp_iso_equiv 
    {x y} (xx : sigma_disp_precat x) (yy : sigma_disp_precat y)
    (f : iso x y)
:= weqpair _ (sigma_disp_iso_isweq xx yy f).
*)

(*
Lemma is_category_sigma_disp (DD : is_category_disp D) (EE : is_category_disp E)
  : is_category_disp sigma_disp_precat.
Proof.
  apply is_category_disp_from_fibers.
  intros x xx yy.
  use weqhomot.
  - destruct xx as [xx xxx], yy as [yy yyy].
     use (@weqcomp _ (∑ ee : xx = yy, transportf (fun r => E (x,,r)) ee xxx = yyy) _ _ _).
      refine (total2_paths_equiv _ _ _).
    set (i := fun (ee : xx = yy) => (total2_paths2 (idpath _) ee)).
    apply @weqcomp with
        (∑ ee : xx = yy, transportf _ (i ee) xxx = yyy).
      apply weqfibtototal; intros ee.
      refine (_ ,, isweqpathscomp0l _ _).
      (* TODO: a pure transport lemma; maybe break out? *)
      destruct ee; apply idpath.
    apply @weqcomp with (∑ ee : xx = yy,
             iso_disp (@idtoiso (total_precat _) (_,,_) (_,,_) (i ee)) xxx yyy).
      apply weqfibtototal; intros ee.
      exists (fun (eee : transportf _ (i ee) xxx = yyy) => idtoiso_disp _ eee).
      apply EE.
    apply @weqcomp with (∑ ee : xx = yy, iso_disp 
         (@total_iso _ D (_,,_) (_,,_) _ (idtoiso_disp (idpath _) ee)) xxx yyy).
      apply weqfibtototal; intros ee.
      mkpair.
        refine (transportf (fun I => iso_disp I xxx yyy) _).
        unfold i.
      (* TODO: maybe break out this lemma on [idtoiso]? *)
      (* Note: [abstract] here is to speed up a [cbn] below. *)
        destruct ee. abstract (apply eq_iso, idpath).
      exact (isweqtransportf (fun I => iso_disp I xxx yyy) _).    
    apply (@weqcomp _ (∑ f : iso_disp (identity_iso x) xx yy,
                      (iso_disp (@total_iso _ D (_,,_) (_,,_) _ f) xxx yyy)) _).
      refine (weqfp (weqpair _ _) _). refine (DD _ _ (idpath _) _ _).
    apply (sigma_disp_iso_equiv (_,,_) (_,,_) _).
  - assert (lemma2 : forall i i' (e : i = i') ii, 
                 pr1 (transportf (fun i => iso_disp i (pr2 xx) (pr2 yy)) e ii)
                 = transportf _ (maponpaths pr1 e) (pr1 ii)).
      intros; destruct e; apply idpath.
    intros ee; apply eq_iso_disp.
    destruct ee, xx as [xx xxx]; cbn.
    apply maponpaths.
    etrans. cbn in lemma2. 
    (* This [match] is to supply the 3rd argument of [lemma2], without referring to the identifier auto-generated by [abstract] above. *)
    match goal with |[ |- pr1 (transportf _ ?H _) = _ ]
      => apply (lemma2 _ _ H _) end.
    refine (@maponpaths_2 _ _ _ _ _ (idpath _) _ _).
    etrans. use maponpaths. apply eq_iso, idpath.
      apply isaset_iso, homset_property.
   apply (@homset_property (total_precat _) (_,,_) (_,,_)).
Qed.
*)

End Sigma.

(** * Displayed functor precategory

Displayed functors and natural transformations form a displayed precategory over the ordinary functor precategory between the bases. *)

Section Functor.
(* TODO: clean up this section a bit. *)

Variables C' C : Precategory.
Variable D' : disp_precat C'.
Variable D : disp_precat C.

Let FunctorsC'C := functor_Precategory C' C.

Lemma foo
  (F' F : functor C' C)
  (a' a : nat_trans F' F)
  (p : a' = a )
  (FF' : functor_over F' D' D)
  (FF : functor_over F D' D)
  (b : nat_trans_over a' FF' FF)
  (c' : C')
  (xx' : D' c')
  :
  pr1 (transportf (fun x => nat_trans_over x FF' FF) p b) c' xx' =
      transportf (mor_disp (FF' c' xx') (FF c' xx')) 
           (nat_trans_eq_pointwise p _ )  (b c' xx'). 
Proof.
  induction p.
  assert (XR : nat_trans_eq_pointwise (idpath a') c' = idpath _ ).
  { apply homset_property. }
  rewrite XR.
  apply idpath.
Qed.

Lemma nat_trans_over_id_left
  (F' F : functor C' C)
  (a : nat_trans F' F)
  (FF' : functor_over F' D' D)
  (FF : functor_over F D' D)
  (b : nat_trans_over a FF' FF)
  :
   nat_trans_over_comp (nat_trans_over_id FF') b =
   transportb (λ f : nat_trans F' F, nat_trans_over f FF' FF) 
              (id_left (a : FunctorsC'C ⟦ _ , _ ⟧)) 
              b.
Proof.
  apply subtypeEquality.
  { intro. apply isaprop_nat_trans_over_axioms. }
  apply funextsec; intro c'.
  apply funextsec; intro xx'.
  apply pathsinv0. 
  etrans. apply foo.
  apply pathsinv0.
  etrans. apply id_left_disp.
  apply transportf_ext, homset_property.
Qed.

Lemma nat_trans_over_id_right
  (F' F : functor C' C)
  (a : nat_trans F' F)
  (FF' : functor_over F' D' D)
  (FF : functor_over F D' D)
  (b : nat_trans_over a FF' FF)
  :
   nat_trans_over_comp b (nat_trans_over_id FF) =
   transportb (λ f : nat_trans F' F, nat_trans_over f FF' FF) 
              (id_right (a : FunctorsC'C ⟦ _ , _ ⟧)) 
              b.
Proof.
  apply subtypeEquality.
  { intro. apply isaprop_nat_trans_over_axioms. }
  apply funextsec; intro c'.
  apply funextsec; intro xx'.
  apply pathsinv0. 
  etrans. apply foo.
  apply pathsinv0.
  etrans. apply id_right_disp.
  apply transportf_ext, homset_property.
Qed.

Lemma nat_trans_over_assoc
  (x y z w : functor C' C)
  (f : nat_trans x y)
  (g : nat_trans y z)
  (h : nat_trans z w)
  (xx : functor_over x D' D)
  (yy : functor_over y D' D)
  (zz : functor_over z D' D)
  (ww : functor_over w D' D)
  (ff : nat_trans_over f xx yy)
  (gg : nat_trans_over g yy zz)
  (hh : nat_trans_over h zz ww)
  :
   nat_trans_over_comp ff (nat_trans_over_comp gg hh) =
   transportb (λ f0 : nat_trans x w, nat_trans_over f0 xx ww) 
     (assoc (f : FunctorsC'C⟦_,_⟧) g h) 
     (nat_trans_over_comp (nat_trans_over_comp ff gg) hh).
Proof.
  apply subtypeEquality.
  { intro. apply isaprop_nat_trans_over_axioms. }
  apply funextsec; intro c'.
  apply funextsec; intro xx'.
  apply pathsinv0.
  etrans. apply foo.
  apply pathsinv0.
  etrans. apply assoc_disp.
  apply transportf_ext.
  apply homset_property.
Qed.

Lemma isaset_nat_trans_over
  (x y : functor C' C)
  (f : nat_trans x y)
  (xx : functor_over x D' D)
  (yy : functor_over y D' D)
  :
   isaset (nat_trans_over f xx yy).
Proof.
  intros. simpl in *.
  apply (isofhleveltotal2 2).
  * do 2 (apply impred; intro).
    apply homsets_disp.
  * intro d. 
    do 6 (apply impred; intro).
    apply hlevelntosn. apply homsets_disp.
Qed.

Definition disp_functor_precat : 
  disp_precat (FunctorsC'C).
Proof.
  mkpair.
  - mkpair.
    + mkpair.
      * intro F.
        apply (functor_over F D' D).
      * simpl. intros F' F FF' FF a.
        apply (nat_trans_over a FF' FF).
    + mkpair.
      * intros x xx.
        apply nat_trans_over_id.
      * intros ? ? ? ? ? ? ? ? X X0. apply (nat_trans_over_comp X X0 ).
  - repeat split.
    + apply nat_trans_over_id_left.
    + apply nat_trans_over_id_right.
    + apply nat_trans_over_assoc.
    + apply isaset_nat_trans_over.      
Defined.

(** TODO : characterize isos in the displayed functor precat *)

Definition pointwise_iso_from_nat_iso {A X : precategory} {hsX : has_homsets X}
  {F G : functor_precategory A X hsX}
  (b : iso F G) (a : A) : iso (pr1 F a) (pr1 G a)
  :=
  functor_iso_pointwise_if_iso _ _ _ _ _ b (pr2 b)_ .


Definition pointwise_inv_is_inv_on {A X : precategory} {hsX : has_homsets X}
  {F G : functor_precategory A X hsX}
  (b : iso F G) (a : A) : 
  
  inv_from_iso (pointwise_iso_from_nat_iso b a) =
                                       pr1 (inv_from_iso b) a. 
Proof.
  apply id_right.
Defined.

(** TODO : write a few lemmas about isos in 
    the disp functor precat, 
    to make the following sane

    However: it seems to be better to work on 
    https://github.com/UniMath/UniMath/issues/362
    first.
*)

Definition is_pointwise_iso_if_is_disp_functor_precat_iso
  (x y : FunctorsC'C)
  (f : iso x y)
  (xx : disp_functor_precat x)
  (yy : disp_functor_precat y)
  (FF : xx -->[ f ] yy)
  (H : is_iso_disp f FF)
  :
  forall x' (xx' : D' x') , is_iso_disp (pointwise_iso_from_nat_iso f _ )
                          (pr1 FF _ xx' ).
Proof.
  intros x' xx'.
  mkpair.
  - set (X:= pr1 H). simpl in X.
    apply (transportb _ (pointwise_inv_is_inv_on f _ ) (X x' xx')).
  - simpl. repeat split.
    + etrans. apply mor_disp_transportf_postwhisker.
      apply pathsinv0.
      apply transportf_comp_lemma.
      assert (XR:= pr1 (pr2 H)).
      assert (XRT :=  (maponpaths pr1 XR)). 
      assert (XRT' :=  toforallpaths _ _ _  (toforallpaths _ _ _ XRT x')).
      apply pathsinv0.
      etrans. apply XRT'. 
      clear XRT' XRT XR.
      assert (XR := foo). 
      specialize (XR _ _ _ _ (! iso_after_iso_inv f)).
      etrans. apply XR.
      apply transportf_ext, homset_property.
    + etrans. apply mor_disp_transportf_prewhisker.      
      apply pathsinv0.
      apply transportf_comp_lemma.
      assert (XR:= inv_mor_after_iso_disp H).
      assert (XRT :=  (maponpaths pr1 XR)). 
      assert (XRT' :=  toforallpaths _ _ _  (toforallpaths _ _ _ XRT x')).
      apply pathsinv0.
      etrans. apply XRT'. 
      clear XRT' XRT XR.
      assert (XR := foo). 
      specialize (XR _ _ _ _ (! iso_inv_after_iso f)).
      etrans. apply XR.
      apply transportf_ext, homset_property.
Defined.

Lemma is_nat_trans_over_pointwise_inv
  (x y : FunctorsC'C)
  (f : iso x y)
  (xx : disp_functor_precat x)
  (yy : disp_functor_precat y)
  (FF : xx -->[ f] yy)
  (H : ∏ (x' : C') (xx' : D' x'),
      is_iso_disp (pointwise_iso_from_nat_iso f x') (pr1 FF x' xx'))
  (x' x0 : C')
  (f0 : x' --> x0)
  (xx' : D' x')
  (xx0 : D' x0)
  (ff : xx' -->[ f0] xx0)
  :
   # (yy : functor_over _ _ _)  ff ;; (let RT := pr1 (H x0 xx0) in
               transportf (mor_disp (pr1 yy x0 xx0) (pr1 xx x0 xx0))
                 (id_right (pr1 (inv_from_iso f) x0)) RT) =
   transportb (mor_disp (pr1 yy x' xx') (pr1 xx x0 xx0))
     (nat_trans_ax (inv_from_iso f) x' x0 f0)
     ((let RT := pr1 (H x' xx') in
       transportf (mor_disp (pr1 yy x' xx') (pr1 xx x' xx'))
         (id_right (pr1 (inv_from_iso f) x')) RT) ;; 
      # (xx : functor_over _ _ _) ff).
Proof.
 etrans. apply mor_disp_transportf_prewhisker.
    apply pathsinv0.
    etrans. apply maponpaths. apply mor_disp_transportf_postwhisker.
(*    Search (transportf _ _ _ = transportf _ _ _ ). *)
(*    Search (?e = ?e' -> ?w = ?w' -> _ ?e ?w = _ ?e' ?w'). *)
    etrans. apply transport_f_f.
(*    Search (transportf _ _ _ = transportf _ _ _ ). *)
    apply transportf_comp_lemma.
    set (Hx := H x' xx').
    assert (Hx1 := pr2 (pr2 Hx)).
    set (XR:= iso_disp_precomp (pointwise_iso_from_nat_iso f x' ) (_ ,,Hx)).
(*    Check (# (pr1 yy) ff ;; pr1 (H x0 xx0)). *)
    specialize (XR _  
       (
        ((# (y : functor _ _ ))%mor f0 ;; inv_from_iso (pointwise_iso_from_nat_iso f x0))
          %mor
         ) 
       ).
    specialize (XR ((xx : functor_over _ _ _  ) x0 xx0)).
    set (Xweq := weqpair _ XR).
    apply (invmaponpathsweq Xweq).
    unfold Xweq. clear Xweq.
    etrans.  apply mor_disp_transportf_prewhisker.
    etrans. apply maponpaths. apply assoc_disp.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply maponpaths_2. apply Hx1.
    etrans. apply maponpaths. apply mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    apply pathsinv0.
    etrans. apply assoc_disp.
    assert (XRO := @nat_trans_over_ax _ _ _ _ _ _ _ _ _ FF).
    specialize (XRO _ _ _ xx'  _ ff).
    assert (XR' := ! (Utilities.transportf_pathsinv0 _ _ _ _  (!XRO))).
    clear XRO.
    clear XR. clear Hx1.
    etrans. apply maponpaths. apply maponpaths_2.
            apply XR'.
    etrans. apply maponpaths.  apply mor_disp_transportf_postwhisker. 
    etrans. apply transport_f_f.
    apply pathsinv0. 
    etrans. apply maponpaths. apply id_left_disp.
    etrans. apply transport_f_f.
    apply pathsinv0.
    
    etrans. apply maponpaths. 
            apply assoc_disp_var.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply maponpaths.
            apply (inv_mor_after_iso_disp (H _ _ )).
    etrans. apply maponpaths. apply mor_disp_transportf_prewhisker. 
    etrans. apply maponpaths. apply maponpaths.
            apply id_right_disp.
    etrans. apply transport_f_f.
    etrans. apply transport_f_f.
    apply transportf_ext. apply homset_property.
Qed.

Definition inv_disp_from_pointwise_iso 
  (x y : FunctorsC'C)
  (f : iso x y)
  (xx : disp_functor_precat x)
  (yy : disp_functor_precat y)
  (FF : xx -->[ f ] yy)
  (H : forall x' (xx' : D' x') , is_iso_disp (pointwise_iso_from_nat_iso f _ )
                          (pr1 FF _ xx' ))
  :     
       yy -->[ inv_from_iso f] xx.
Proof.
  mkpair.
  + intros x' xx'.
    simpl in xx. simpl in yy.
    assert (XR : inv_from_iso (pointwise_iso_from_nat_iso f x') =
                                       pr1 (inv_from_iso f) x').
    { apply id_right. }
    set (RT := pr1 (H x' xx')).
    apply (transportf _ XR RT).
  + intros x' x0 f0 xx' xx0 ff.
    apply is_nat_trans_over_pointwise_inv.
Defined.
    
    

Definition is_disp_functor_precat_iso_if_pointwise_iso 
  (x y : FunctorsC'C)
  (f : iso x y)
  (xx : disp_functor_precat x)
  (yy : disp_functor_precat y)
  (FF : xx -->[ f ] yy)
  (H : forall x' (xx' : D' x') , is_iso_disp (pointwise_iso_from_nat_iso f _ )
                          (pr1 FF _ xx' ))
  : is_iso_disp f FF.
Proof.  
  mkpair.
  - apply (inv_disp_from_pointwise_iso _ _ _ _ _ FF H).
  - split.
    + apply subtypeEquality.
      { intro. apply isaprop_nat_trans_over_axioms. }
      apply funextsec; intro c'.
      apply funextsec; intro xx'.
      apply pathsinv0.
      etrans. apply foo.
      cbn.
      apply pathsinv0.
      etrans. apply mor_disp_transportf_postwhisker.
      etrans. apply maponpaths. apply (iso_disp_after_inv_mor (H c' xx')).
      etrans. apply transport_f_f.
      apply transportf_ext, homset_property.
    + apply subtypeEquality.
      { intro. apply isaprop_nat_trans_over_axioms. }
      apply funextsec; intro c'.
      apply funextsec; intro xx'.
      apply pathsinv0.
      etrans. apply foo.
      cbn.
      apply pathsinv0.
      etrans. apply mor_disp_transportf_prewhisker.
      etrans. apply maponpaths. apply (inv_mor_after_iso_disp (H c' xx')).
      etrans. apply transport_f_f.
      apply transportf_ext, homset_property.
Defined.      

End Functor.

(** * Fiber precategories *)

(** A displayed category gives a _fiber_ category over each object of the base.  These are most interesting in the case where the displayed category is an isofibration. *)
Section Fiber.

Context {C : Precategory}
        (D : disp_precat C)
        (c : C).

Definition fiber_precategory_data : precategory_data.
Proof.
  mkpair.
  - mkpair.
    + apply (ob_disp D c).
    + intros xx xx'. apply (mor_disp xx xx' (identity c)).
  - mkpair.
    + intros. apply id_disp.
    + intros. apply (transportf _ (id_right _ ) (comp_disp X X0)).
Defined.

Lemma fiber_is_precategory : is_precategory fiber_precategory_data.
Proof.
  repeat split; intros; cbn.
  - etrans. apply maponpaths. apply id_left_disp.
    etrans. apply transport_f_f. apply transportf_comp_lemma_hset. 
    apply (homset_property). apply idpath.
  - etrans. apply maponpaths. apply id_right_disp.
    etrans. apply transport_f_f. apply transportf_comp_lemma_hset. 
    apply (homset_property). apply idpath.
  - etrans. apply maponpaths. apply mor_disp_transportf_prewhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply assoc_disp.
    etrans. apply transport_f_f.
    apply pathsinv0. 
    etrans. apply maponpaths.  apply mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    apply transportf_ext. apply homset_property.
Qed.

Definition fiber_precategory : precategory := ( _ ,, fiber_is_precategory).

Lemma has_homsets_fiber : has_homsets fiber_precategory.
Proof.
  intros x y. apply homsets_disp.
Qed.



Definition iso_disp_from_iso_fiber (a b : fiber_precategory) :
  iso a b -> iso_disp (identity_iso c) a b.
Proof.
 intro i.
 mkpair.
 + apply (pr1 i).
 + cbn. 
   mkpair. 
   * apply (inv_from_iso i).
   * abstract (  split;
       [ assert (XR := iso_after_iso_inv i);
        cbn in *;
        assert (XR' := transportf_pathsinv0_var XR);
        etrans; [ apply (!XR') |];
        apply transportf_ext; apply homset_property
       |assert (XR := iso_inv_after_iso i);
        cbn in *;
        assert (XR' := transportf_pathsinv0_var XR);
        etrans; [ apply (!XR') | ];
        apply transportf_ext; apply homset_property ] ).
Defined.

Definition iso_fiber_from_iso_disp (a b : fiber_precategory) :
  iso a b <- iso_disp (identity_iso c) a b.
Proof.
  intro i.
  mkpair.
  + apply (pr1 i).
  + cbn in *. 
    apply (@is_iso_from_is_z_iso fiber_precategory).
    mkpair.
    apply (inv_mor_disp_from_iso i).
    abstract (split; cbn;
              [
                assert (XR := inv_mor_after_iso_disp i);
                etrans; [ apply maponpaths , XR |];
                etrans; [ apply transport_f_f |];
                apply transportf_comp_lemma_hset;
                  try apply homset_property; apply idpath
              | assert (XR := iso_disp_after_inv_mor i);
                etrans; [ apply maponpaths , XR |] ;
                etrans; [ apply transport_f_f |];
                apply transportf_comp_lemma_hset;
                try apply homset_property; apply idpath
              ]). 
Defined.

Lemma iso_disp_iso_fiber (a b : fiber_precategory) :
  iso a b ≃ iso_disp (identity_iso c) a b.
Proof.
  exists (iso_disp_from_iso_fiber a b).
  use (gradth _ (iso_fiber_from_iso_disp _ _ )).
  - intro. apply eq_iso. apply idpath.
  - intro. apply eq_iso_disp. apply idpath.
Defined.
    
(** ** Univalence *)
Variable H : is_category_disp D.

Let idto1 (a b : fiber_precategory) : a = b ≃ iso_disp (identity_iso c) a b 
  := 
  weqpair (@idtoiso_fiber_disp _ _ _ a b) (H _ _ (idpath _ ) a b).

Let idto2 (a b : fiber_precategory) : a = b -> iso_disp (identity_iso c) a b 
  := 
  funcomp (λ p : a = b, idtoiso p) (iso_disp_iso_fiber a b).

Lemma eq_idto1_idto2 (a b : fiber_precategory) 
  : ∏ p : a = b, idto1 _ _ p = idto2 _ _ p.
Proof.
  intro p. induction p.
  apply eq_iso_disp.
  apply idpath.
Qed.

Lemma is_univalent_fiber_precat 
  (a b : fiber_precategory)
  :
  isweq (λ p : a = b, idtoiso p).
Proof.
  use (twooutof3a _ (iso_disp_iso_fiber a b)). 
  - use (isweqhomot (idto1 a b)).
    + intro p.
      apply eq_idto1_idto2.
    + apply weqproperty.
  - apply weqproperty.
Defined.    


Lemma is_category_fiber : is_category fiber_precategory.
Proof.
  split.
  - apply is_univalent_fiber_precat.
  - apply has_homsets_fiber.
Defined.

End Fiber.

Arguments fiber_precategory {_} _ _ .

(* TODO: is this a terrible notation?  Probably. *)
Notation "D [{ x }]" := (fiber_precategory D x)(at level 3,format "D [{ x }]").

(** ** Fiber functors

Functors between displayed categories induce functors between their fibers. *)
Section Fiber_Functors.

Section fix_context.

Context {C C' : Precategory} {D} {D'}
        {F : functor C C'} (FF : functor_over F D D')
        (x : C).

Definition fiber_functor_data : functor_data D[{x}] D'[{F x}].
Proof.
  mkpair.
  - apply (fun xx' => FF xx').
  - intros xx' xx ff.
    apply (transportf _ (functor_id _ _ ) (# FF ff)).
Defined.

Lemma is_functor_fiber_functor : is_functor fiber_functor_data.
Proof.
  split; unfold functor_idax, functor_compax; cbn.
  - intros.
    apply Utilities.transportf_pathsinv0.
    apply pathsinv0. apply functor_over_id.
  - intros.
    etrans. apply maponpaths. apply functor_over_transportf.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply functor_over_comp.
    etrans. apply transport_f_f.
    apply pathsinv0.
    etrans. apply maponpaths. apply mor_disp_transportf_prewhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths. apply mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    apply transportf_ext, homset_property.
Qed.

Definition fiber_functor : functor D[{x}] D'[{F x}]
  := ( _ ,, is_functor_fiber_functor).

End fix_context.

(* TODO: consider lemma organisation in this file *)

Definition is_iso_fiber_from_is_iso_disp
  {C : Precategory} {D : disp_precat C}
  {c : C} {d d' : D c} (ff : d -->[identity c] d')
  (Hff : is_iso_disp (identity_iso c) ff)
: @is_iso (fiber_precategory D c) _ _ ff.
Proof.
  apply is_iso_from_is_z_iso.
  exists (pr1 Hff).
  mkpair; cbn.
  + set (H := pr2 (pr2 Hff)).
    etrans. apply maponpaths, H.
    etrans. apply transport_f_b.
    refine (@maponpaths_2 _ _ _ _ _ (paths_refl _) _ _).
    apply homset_property.      
  + set (H := pr1 (pr2 Hff)).
    etrans. apply maponpaths, H.
    etrans. apply transport_f_b.
    refine (@maponpaths_2 _ _ _ _ _ (paths_refl _) _ _).
    apply homset_property.
Qed.

Definition fiber_nat_trans {C C' : Precategory}
  {F : functor C C'}
  {D D'} {FF FF' : functor_over F D D'}
  (α : nat_trans_over (nat_trans_id F) FF FF')
  (c : C)
: nat_trans (fiber_functor FF c) (fiber_functor FF' c).
Proof.
  use tpair; simpl.
  - intro d. exact (α c d).
  - unfold is_nat_trans; intros d d' ff; simpl.
    set (αff := pr2 α _ _ _ _ _ ff); simpl in αff.
    cbn.
    etrans. apply maponpaths, mor_disp_transportf_postwhisker.
    etrans. apply transport_f_f.
    etrans. apply maponpaths, αff.
    etrans. apply transport_f_b.
    apply @pathsinv0.
    etrans. apply maponpaths, mor_disp_transportf_prewhisker.
    etrans. apply transport_f_f.
    apply maponpaths_2, homset_property.
Defined.

Lemma fiber_functor_ff
    {C C' : Precategory} {D} {D'}
    {F : functor C C'} (FF : functor_over F D D')
    (H : functor_over_ff FF)
    (c : C)
: fully_faithful (fiber_functor FF c).
Proof.
  intros xx yy; cbn.
  set (XR := H _ _ xx yy (identity _ )).
  apply twooutof3c.
  - apply XR.
  - apply isweqtransportf.
Defined.

End Fiber_Functors.


