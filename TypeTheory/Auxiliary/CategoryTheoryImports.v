(**
  [TypeTheory.Auxiliary.CategoryTheoryImports]

  Part of the [TypeTheory] library (Ahrens, Lumsdaine, Voevodsky, 2015–present).
*)

(** A wrapper, re-exporting the modules from [UniMath] that we frequently use, to reduce clutter in imports. *)

Require Export UniMath.CategoryTheory.limits.pullbacks.
Require Export UniMath.Foundations.Propositions.
Require Export UniMath.CategoryTheory.precategories.
Require Export UniMath.CategoryTheory.functor_categories.
Require Export UniMath.CategoryTheory.opp_precat.
Require Export UniMath.CategoryTheory.functor_categories.
Require Export UniMath.CategoryTheory.whiskering.
Require Export UniMath.CategoryTheory.opp_precat.
Require Export UniMath.CategoryTheory.Adjunctions.
Require Export UniMath.CategoryTheory.equivalences.
Require Export UniMath.CategoryTheory.precomp_fully_faithful.
Require Export UniMath.CategoryTheory.rezk_completion.
Require Export UniMath.CategoryTheory.yoneda.
Require Export UniMath.CategoryTheory.category_hset.

Open Scope cat.
Open Scope cat_deprecated.