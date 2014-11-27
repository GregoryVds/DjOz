%\define DebugTest
local

   fun {AssertEqualFloats Float1 Float2}
      Ratio = Float1/Float2
   in
      {And (Ratio>0.999) (Ratio<1.001)}
   end

   fun {AssertEqualValues Value1 Value2}
      if {IsFloat Value1} then
	 {AssertEqualFloats Value1 Value2}
      else
	 Value1==Value2
      end
   end
   
   fun {AssertEqualLists L1 L2}
      if ({Length L1} == {Length L2}) then
	 case L1
	 of nil then L1 == L2
	 [] H|T then {And {AssertEqualValues H L2.1} {AssertEqualLists T L2.2}}
	 end
      else
	 false	 
      end   
   end

   proc {PrintAssertionMessage Result Function Expected Got Args}
      if Result then
	 {Browse assertion_pass(Function)}
      else
	 {Browse assertion_fail(Function expected:Expected got:Got args:Args)}
      end
   end
     	 
   % Testing routine that asserts that the functions returns what is expected. 
   % Args can either be a single argument or a list of arguments.
   proc {AssertEqual Function Args Expected}
      Got ApplyArg AssertResult
   in
      ApplyArg = case Args
		 of _|_ then {Append Args [Got]}
		 [] _   then {Append [Args] [Got]}
		 end
      {Procedure.apply Function ApplyArg}

     
      AssertResult = if {IsList Got} then
			{AssertEqualLists Got Expected}
		     else
			{AssertEqualValues Got Expected}
		     end
           
      {PrintAssertionMessage AssertResult Function Expected Got Args}
   end


   
in
   \ifdef DebugTest
   {Browse 'export'(assertEqual:AssertEqual)}   
   \else
   'export'(assertEqual:AssertEqual)
   \endif
end
 \undef DebugTest