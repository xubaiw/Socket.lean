import Socket

open Socket

def main : IO Unit := do
  IO.println (← hostname)

