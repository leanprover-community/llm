/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/

/-!
# Running external commands.
-/

namespace LLM

open System (FilePath)

open IO.Process in
/--
Pipe input into stdin of the spawned process,
then return (exitCode, stdout, stdErr) upon completion.
-/
-- TODO Put this somewhere central / share with `cache` executable.
def runCmd' (cmd : String) (args : Array String) (throwFailure := true) (input : String := "") :
    IO (UInt32 × String × String) := do
  let child ← spawn
    { cmd := cmd, args := args, stdin := .piped, stdout := .piped, stderr := .piped }
  let (stdin, child) ← child.takeStdin
  stdin.putStr input
  stdin.flush
  let stdout ← IO.asTask child.stdout.readToEnd Task.Priority.dedicated
  let err ← child.stderr.readToEnd
  let exitCode ← child.wait
  if exitCode != 0 && throwFailure then
    throw $ IO.userError err
  else
    let out ← IO.ofExcept stdout.get
    return (exitCode, out, err)

def runCmd (cmd : String) (args : Array String) (throwFailure := true) (input : String := "") :
    IO String := do
  return (← runCmd' cmd args throwFailure input).2.1