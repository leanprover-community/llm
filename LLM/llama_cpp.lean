/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import LLM.ChatBot

/-!
# Interface for `llama.cpp`.
-/

open System (FilePath)

namespace LLM

/-- Help text for installing `llama.cpp`. -/
def llama_cpp_instructions : String :=
"* Clone the `llama.cpp` repository from https://github.com/ggerganov/llama.cpp.
  Set the environment variable `LLAMA_CPP_HOME` to this repository.
  Follow the instructions in the README to produce `7B/ggml-model-q4_0.bin`
  starting from the Meta LLaMa weights.
  You can store this file at one of
  * `$LLAMA_CPP_HOME/models/7B/ggml-model-q4_0.bin`
  * `$HOME/.models/7B/ggml-model-q4_0.bin`
  * `$LLM_MODELS/7B/ggml-model-q4_0.bin`
"

/-- Instantiate an LLM running locally using the llama.cpp library. -/
def llama_cpp_LLM (path : FilePath) (model : String) (modelHome : Option FilePath := none) :
    IO LLM := do
  let main := path / "main"
  if ! (← main.pathExists) then
    throw <| IO.userError <| "Could not find `llama.cpp` executable.\n" ++ llama_cpp_instructions
  let modelPath ← try
    findModel model (modelHome.toList ++ [path / "models"])
  catch e => throw <| IO.userError <| e.toString ++ "\n" ++ llama_cpp_instructions
  pure <|
  { run := fun input cfg => do
      -- Unfortunately I haven't been able to get `llama.cpp`
      -- to react properly when providing the prompt on stdin,
      -- so we use a temporary file.
      let promptFile := path / "prompts" / "lean-prompt.txt"
      IO.FS.writeFile promptFile input
      let result ← runCmd (toString main) <|
        #["-m", toString modelPath, "-f", toString promptFile]
          ++ match cfg.stopToken with
          | some t => #["-r", t]
          | none => #[]
          ++ match cfg.maxTokens with
          | some m => #["-n", toString m]
          | none => #[]
      -- TODO can we delete `promptFile`?
      return result.trim.stripPrefix input }

/-- Instantiate a chat bot running locally using the llama.cpp library. -/
def llama_cpp (model : String := "7B/ggml-model-q4_0.bin"): IO ChatBot := do
  let path : FilePath ← match ← IO.getEnv "LLAMA_CPP_HOME" with
  | some home => pure home
  | none => throw <| IO.userError <|
      "Please set the environment variable LLAMA_CPP_HOME to point to your llama.cpp directory.\n"
        ++ llama_cpp_instructions
  let llm ← llama_cpp_LLM path model
  return llm.asChatBot