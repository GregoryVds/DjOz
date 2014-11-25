% \define DebugTest
local

   fun {AssertEqualFloats Float1 Float2}
      Ratio = Float1/Float2
   in
      {And (Ratio>0.999) (Ratio<1.001)}
   end
   
   % Testing routine that asserts that the functions returns what is expected. 
   % Args can either be a single argument or a list of arguments.
   proc {AssertEqual Function Args Expected}
      Got ApplyArg Message AssertResult
   in
      ApplyArg = case Args
		 of _|_ then {Append Args [Got]}
		 [] _   then {Append [Args] [Got]}
		 end
      {Procedure.apply Function ApplyArg}

      AssertResult = if {IsFloat Expected} then
			{AssertEqualFloats Got Expected}
		     else
			Expected==Got
		     end
     
      Message = if AssertResult then
		   assertion_pass(Function)
		else
		   assertion_fail(Function expected:Expected got:Got args:Args)
		end

      {Browse Message}
   end

in
   \ifdef DebugTest
   {Browse 'export'(assertEqual:AssertEqual)}   
   \else
   'export'(assertEqual:AssertEqual)
   \endif
end
 \undef DebugTest