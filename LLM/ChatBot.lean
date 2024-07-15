/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import LLM.String
import LLM.GPT.Json

/-!
# Abstract interfaces for large language models and chat bots.
-/

namespace LLM

open GPT

/-- Abstract interface for a chat bot. -/
structure ChatBot where
  /--- Given a chat history so far, retrieve the next response. -/
  sendMessages : List Message → IO String

open System (FilePath)
open IO

/-- Configuration settings applicable to all LLMs. -/
structure LLMConfig where
  /-- Stop generating tokens if the `stopToken` appears. -/
  stopToken : Option String := none
  /-- Stop generating after `maxTokens` tokens. -/
  maxTokens : Option Nat := none

/-- Abstract interface for an LLM. -/
structure LanguageModel where
  run (input : String) (cfg : LLMConfig := {}) : IO String

/-- Treat an LLM as a chat bot, by concatenating the conversation so far with prompts. -/
def LanguageModel.asChatBot (L : LanguageModel)
    (userCue : String := "User") (assistantCue : String := "Assistant") : ChatBot where
  sendMessages msgs := do
      let input := ("\n".intercalate <| msgs.map fun ⟨role, content⟩ => match role with
        | .system => content
        | .user => "\n" ++ userCue ++ ": " ++ content
        | .assistant => assistantCue ++ ": " ++ content)
        ++ "\n" ++ assistantCue ++ ": "
      let result ← L.run (cfg := { stopToken := userCue ++ ":" }) input
      return result.trim.stripSuffix' (userCue ++ ":") |>.trim

/-- Locate a model file, searching a list of paths, as well as `$LLM_MODELS` and `$HOME/.models`. -/
def findModel (model : String) (searchPaths : List FilePath) : IO FilePath := do
  let searchPaths : List FilePath := searchPaths
    ++ ((← IO.getEnv "LLM_MODELS").map (fun p => (p : FilePath)) |>.toList)
    ++ ((← IO.getEnv "HOME").map (fun p => (p : FilePath) / ".models") |>.toList)
  match ← (searchPaths.map fun p => p / model).findM? (fun p => p.pathExists) with
  | some p => return p
  | none => throw <| IO.userError s!"Could not find {model} in any of the paths: {searchPaths}"
