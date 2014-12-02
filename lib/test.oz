% Author: VANDER SCHUEREN Gregory
% Date: December 2014

local

   fun {AssertEqualFloats Float1 Float2}
      Ratio
   in
      if {And (Float1==0.0) (Float2==0.0)} then
	 true
      else
	 Ratio = Float1/Float2
	 {And (Ratio>0.999) (Ratio<1.001)}
      end
   end

   fun {AssertEqualValues Value1 Value2}
      if {IsFloat Value1} then
	 {AssertEqualFloats Value1 Value2}
      else
	 Value1==Value2
      end
   end
   
   fun {AssertEqualLists L1 L2}
      case L1
      of nil then
	 case L2
	 of nil then L1 == L2
	 [] _|_ then false
	 end
      [] H|T then
	 case L2
	 of nil then false
	 [] H2|T2 then {And {AssertEqualValues H H2} {AssertEqualLists T T2}}
	 end
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
   'export'(assertEqual:AssertEqual assertEqualLists:AssertEqualLists assertEqualFloats:AssertEqualFloats)
end