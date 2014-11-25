local

   % Testing routine that asserts that the functions returns what is expected. 
   % Args can either be a single argument or a list of arguments.
   proc {AssertEqual Function Args Expected}
      Got Message ApplyArg AssertionPass
   in
      ApplyArg = case Args
		 of _|_ then {Append Args [Got]}
		 [] _   then {Append [Args] [Got]}
		 end
      {Procedure.apply Function ApplyArg}

      AssertionPass = if ({IsFloat Expected}) then
			 {Browse {FloatToInt Expected}}
			 {Browse {FloatToInt Got}}
			 {FloatToInt Expected}=={FloatToInt Got}
		      else
			 Expected==Got
		      end

      Message = if AssertionPass then
		   assertion_pass(Function)
		else
		   assertion_fail(Function expected:Expected got:Got args:Args)
		end

      {Browse Message}
   end
in
   'export'(assertEqual:AssertEqual)
end