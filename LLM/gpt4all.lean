/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import LLM.ChatBot
import Batteries.Lean.IO.Process

/-!
# Interfacoe for `gpt4all`.
-/

open System (FilePath)
open IO.Process

namespace LLM

/-- Help text for using gpt4all via the python bindings. -/
def gpt4all_instructions :=
"* Download the GPT4All-J model `https://gpt4all.io/models/ggml-gpt4all-j-v1.3-groovy.bin`,
  and put it in either `$HOME/.models/` or `$LLM_MODELS`.
  Also install the gpt4all python bindings via `pip3 install pygpt4all`.
"

/-- Find the directory containing the LLM package. -/
def llmRoot : IO FilePath := do
  if ← FilePath.mk "LLM" |>.pathExists then
    return "."
  else
    return "lake-packages" / "llm"

/-- Instantiate an LLM running locally using the pygpt4all library. -/
def gpt4all_LanguageModel (model : String) (modelHome : Option FilePath := none) :
    IO LanguageModel := do
  let main := (← llmRoot) / "LLM/pygpt4all-prompt.py"
  let modelPath ← try
    findModel model modelHome.toList
  catch e =>
    IO.println e.toString
    IO.println gpt4all_instructions
    throw e
  pure <|
    { run := fun input cfg => do
        -- TODO pass cfg.maxTokens
        -- Hacky: `pygpt4all` pollutes `stdout`, so our script prints on `stderr`.
        -- See https://github.com/nomic-ai/pygpt4all/issues/100
        let ⟨_, _, result⟩ ← runCmdWithInput' (toString main) #[toString modelPath, cfg.stopToken.getD ""]
          input (throwFailure := false)
        return result.stripSuffix' "done" |>.trim }

/-- Instantiate a chat bot running locally using the pygpt4all library. -/
def gpt4all (model : String := "ggml-gpt4all-j-v1.3-groovy.bin") : IO ChatBot := do
  try
    _ ← runCmdWithInput (toString <| (← llmRoot) / "LLM/pygpt4all-noop.py") #[]
  catch e =>
    IO.println "Could not find the pygpt4all library."
    IO.println "Try running `pip3 install pygpt4all`."
    throw e
  return (← gpt4all_LanguageModel model).asChatBot
