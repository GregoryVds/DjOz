local

   % Testing routine that asserts that the functions returns what is expected. 
   % Args can either be a single argument or a list of arguments.
   proc {AssertEqual Function Args Expected}
      Got Message ApplyArg
   in
      ApplyArg = case Args
		 of _|_ then {Append Args [Got]}
		 [] _   then {Append [Args] [Got]}
		 end
      {Procedure.apply Function ApplyArg}
      Message = (if Expected==Got then assertion_pass(Function) else assertion_fail(Function expected:Expected got:Got args:Args) end)
      {Browse Message}
   end
in
   'export'(assertEqual:AssertEqual)
end