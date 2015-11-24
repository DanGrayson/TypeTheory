
(**

 Ahrens, Lumsdaine, Voevodsky, 2015

  Contents:

    - Definition of a precategory with families
    - Proof that reindexing forms a pullback

  The definition is based on Pitts, *Nominal Presentations of the Cubical Sets
  Model of Type Theory*, Def. 3.1: 
  http://www.cl.cam.ac.uk/~amp12/papers/nompcs/nompcs.pdf (page=9)
*)

Require Export Systems.Auxiliary.
Require Export Systems.UnicodeNotations.
Require Export UniMath.CategoryTheory.functor_categories.
Require Export UniMath.CategoryTheory.category_hset.
Require Export UniMath.CategoryTheory.opp_precat.
Require Export UniMath.Foundations.Sets.
Require Export UniMath.CategoryTheory.limits.pullbacks.

Require Import CwF.
Require Import CwF_1.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "C '^op'" := (opp_precat C) (at level 3, format "C ^op").


Section fix_a_precategory.
  
  Variable C : precategory.

  Section CwF_1_from_CwF.
  
  Variable CC : CwF.cwf_struct C.

  Definition type_functor : functor C^op HSET.
  Proof.
    refine (tpair _ _ _ ).
    - exists (fun Γ => hSetpair
                         (CwF.type CC Γ)
                         (CwF.cwf_types_isaset CC Γ) ).
      simpl.
      intros a b f A.
      apply (CwF.rtype A f).
    -  split; intros; simpl.
       + intro Γ; simpl;
         apply funextfun; intro A;
         apply CwF.reindx_type_id;
         apply (CwF.reindx_laws_from_cwf_struct _ CC).
       + intros Γ Γ' Γ'' γ γ';
         apply funextfun; intro A;
         apply CwF.reindx_type_comp;
         apply (CwF.reindx_laws_from_cwf_struct _ CC).
  Defined.

  Definition CwF_1_from_CwF : CwF_1.cwf_struct C.
  Proof.
    refine (tpair _ _ _ ).
    - refine (tpair _ _ _ ).
      + refine (tpair _ _ _ ).
        * { refine (tpair _ _ _ ).
            - refine (tpair _ _ _ ).
              + apply type_functor.
              + simpl. intros Γ A. apply (CwF.term CC Γ A).
            - intros Γ Γ' A a γ. simpl in *.
              apply (CwF.rterm a γ).
          }
        * intros Γ A. simpl in *.
          exists (CwF.comp_obj Γ A).
          exact (CwF.proj_mor  A).
      + simpl.
        intros Γ A; simpl in *.
        refine (dirprodpair _ _ ).
        * apply (CwF.gen_elem  _ ).
        * intros Γ' γ a.
          apply (CwF.pairing γ a ).
    - simpl.
      repeat split.
      + simpl.
        refine (tpair _ _ _ ).
        * simpl.
          {   refine (tpair _ _ _ ).
               - simpl;
                 intros Γ A a.
                 assert (T:= CwF.reindx_term_id CC).
                 eapply pathscomp0. apply T.
                 simpl.
                 unfold functor_id.
                 simpl. (* here is the first place where we get a propositional equality instead of
                           the desired definitional one *)
                 apply idpath.
                 apply transportf_ext;
                 apply proofirrelevance;
                 apply (CwF.cwf_types_isaset).
               -  simpl;
                        intros;
                        assert (T:= @CwF.reindx_term_comp _ CC);
                        eapply pathscomp0; [apply T|];
                        apply transportf_ext;
                        apply proofirrelevance;
                        apply (CwF.cwf_types_isaset)
                      ])
              .
          }
        * { repeat split; simpl.
            - intros Γ A Γ' γ a.
              refine (tpair _ _ _ ).
              + simpl in A, a.
                apply (CwF.cwf_law_1).
              + simpl in *.
                assert (T:=CwF.cwf_law_2 CC).
                eapply pathscomp0. Focus 2. apply T.
                apply map_on_two_paths.
                * apply proofirrelevance. apply (CwF.has_homsets_cwf CC).
                * apply transportf_ext. apply (CwF.cwf_types_isaset CC).
            - intros ? ? ? ? ? ? ? .
              simpl in *.
              assert (T:= CwF.cwf_law_3 CC).
              unfold CwF.comp_law_3 in T.
              eapply pathscomp0. apply T.
              apply maponpaths.
              apply transportf_ext.
              apply (CwF.cwf_types_isaset CC).
            - intros ? ? .
              simpl in *.
              assert (T:=CwF.cwf_law_4 CC).
              apply T.
          }
      + apply (CwF.has_homsets_cwf CC).
      + simpl.
        apply (CwF.cwf_terms_isaset CC).
        Unshelve.
        (apply (CwF.reindx_laws_from_cwf_struct _ CC)).
  Defined.

  End CwF_1_from_CwF.

  Section CwF_from_CwF_1.

    Variable CC : CwF_1.cwf_struct C.

    Definition CwF_from_CwF_1 : CwF.cwf_struct C.
    Proof.
      refine (tpair _ _ _ ).
      - refine (tpair _ _ _ ).
        + refine (tpair _ _ _ ).
          * {
              refine (tpair _ _ _ ).
              - refine (tpair _ _ _ ).
                + intro Γ.
                  apply (CwF_1.type CC Γ).
                + simpl.
                  intros Γ A.
                  apply (CwF_1.term CC Γ A).
              - simpl.
                refine (tpair _ _ _ ).
                + simpl.
                  intros Γ Γ' A γ.
                  apply (rtype A γ).
                + simpl.
                  intros Γ Γ' A a γ.
                  apply (rterm a γ).
            }
          * intros Γ A.
            exists (comp_obj Γ A).
            exact (proj_mor A).
        + intros Γ A.
          split; simpl.
          * simpl in A.
            apply (gen_elem).
          * simpl in A.
            intros Γ' γ a.
            apply (pairing γ a).
      - simpl.
        repeat split; simpl.
        + refine (tpair _ _ _ ).
          * {
              refine (tpair _ _ _ ).
              - unfold CwF.reindx_laws_type.
                split; simpl.
                + intros Γ A.
                  apply (CwF_1.reindx_type_id).
                + intros.
                  apply (CwF_1.reindx_type_comp).
              - split.
                + simpl.
                  intros Γ A a.
                  apply (CwF_1.reindx_term_id).
                  apply                 
                           (CwF_1.reindx_laws_from_cwf_struct _ CC).
                + simpl.
                  intros.
                  apply (CwF_1.reindx_term_comp).
                  apply                 
                           (CwF_1.reindx_laws_from_cwf_struct _ CC).
            }
          * { split.
              - intros ? ? ? ? ? .
                simpl in * |-.
                refine (tpair _ _ _ ).
                + apply (CwF_1.cwf_law_1).
                + assert (T:=CwF_1.cwf_law_2 CC).
                  eapply pathscomp0. Focus 2. apply T.
                  apply map_on_two_paths.
                  * apply proofirrelevance.
                    apply (CwF_1.has_homsets_cwf CC).
                  * apply transportf_ext.
                    apply proofirrelevance.
                    apply (CwF_1.cwf_types_isaset CC).
              - split.
                + intros ? ? ? ? ? ? ? .
                  simpl in *|-.
                  assert (T:= CwF_1.cwf_law_3 CC).
                  unfold comp_law_3 in T.
                  eapply pathscomp0. apply T.
                  apply maponpaths.
                  apply transportf_ext.
                  apply (CwF_1.cwf_types_isaset CC).
                + intros ? ? .
                  simpl in A.
                  apply (CwF_1.cwf_law_4 CC).
            }
        + apply (CwF_1.has_homsets_cwf CC).
        + intro Γ. apply setproperty.
        + intros Γ A.
          apply (CwF_1.cwf_terms_isaset CC).
    Defined.

  End CwF_from_CwF_1.

  
    Lemma bla (CC : CwF_1.cwf_struct C) : CwF_1_from_CwF (CwF_from_CwF_1 CC) = CC.
    Proof.
      apply (subtypeEquality).
      apply (isPredicate_cwf_laws).
      destruct CC as [CC1 CClaws].
      destruct CC1 as [CC1 CC2].
      destruct CC1 as [CC1a CC1b].
      destruct CC1a as [A B].
      destruct A as [a b].
      refine (total2_paths _ _ ).
      - simpl.
        refine (total2_paths _ _ ).
        + simpl.
          refine (total2_paths _ _ ).
          * simpl.
            refine (total2_paths _ _ ).
            simpl.
            destruct a as [t p].
            refine (total2_paths _ _ ).
            simpl.
            destruct t as [t1 t2].
            refine (total2_paths _ _ ).
            simpl.
            destruct CClaws as [c d].
            destruct c as [c1 c2].
            destruct c2 as [c2 c3].
            destruct c3 as [c3 c4].
            
            simpl in *.
            apply funextfun; intro.
            destruct p as [p1 p2].
            simpl in *.
            destruct d as [d1 d2].
            simpl in *.
            refine (total2_paths _ _ ).
            apply idpath.
            apply idpath.
            simpl in *.
            apply idpath.
            destruct (t1 x).
            refine (total2_paths _ _ ).
            simpl.
            apply idpath.

            simpl.
            
            apply idpath.
            simpl.
            apply idpath.
            apply idpath.
            
          apply idpath.
      apply idpath.
      apply idpath.
      destruct CC2 as [x y].
                  
                    (*Focus 2. apply T.
                apply transportf_ext.
*)

                Search (?f _ _ = ?f _ _ ).
          
Search (transportf _ _ _ = transportf _ _ _ ).
              