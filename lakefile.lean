import Lake

open Lake DSL

package llm where

@[default_target]
lean_lib LLM where

@[default_target]
lean_exe runLinter where
  root := `scripts.runLinter
  supportInterpreter := true

require std from git "https://github.com/leanprover/std4" @ "main"
