/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/

/-!
# Additional functions on `String`.
-/

namespace String

/-- `s.stripPrefix p` will remove `p` from the beginning of `s` if it occurs there,
or otherwise return `s`. -/
def stripPrefix (s p : String) :=
  if s.startsWith p then s.drop p.length else s

/-- `s.stripSuffix p` will remove `p` from the end of `s` if it occurs there,
or otherwise return `s`. -/
def stripSuffix (s p : String) :=
  if s.endsWith p then s.dropRight p.length else s