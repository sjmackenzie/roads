functor
import
   Support(ul:UL labelled:Labelled)
   JavaScriptCode
export
   '':Menu
   Create
   Delete
   MakeAdmin
   Before
   After
define
   fun {Menu Session}
      h1("Administration") %% see After
   end

   fun {Create Session}
      Question
   in
      'div'(h1("Create a poll: Question")
	    form({Labelled "Enter the question: "
		  input(type:text id:"Question" bind:Question
			validate:length_in(1 1000))}
		 input(type:submit value:"Submit question")
		 action:fun {$ S}
			   {S.set question Question.escaped}
			   {EnterOptions S}
			end
		 method:post
		)
	   )
   end

   fun {EnterOptions Session}
      Question = {Session.get question}
      Answers = {Session.condGet answers nil}
      NewAnswer
   in
      'div'(
	 h1("Create a poll: Options")
	 "Question: "#Question br
	 {ShowAnswers Answers} br
	 form(
	    {Labelled "Enter a new option: "
	     input(type:text bind:NewAnswer id:"Option"
		   validate:length_in(1 1000))}
	    input(type:submit name:"submit" value:"Submit option") br
	    method:post
	    action:fun {$ S}
		      {S.set answers {Append Answers [NewAnswer.escaped]}}
		      {EnterOptions S}
		   end
	    a("Done"
	      href:fun {$ S}
		      NewPollId = {S.model createPoll(Question Answers result:$)}
		   in
		      'div'("Poll added. " br
			    a("View new poll"
			      href:url('functor':'' function:show
				       params:unit(pollid:NewPollId))
			      )
			   )
		   end
	     )
	    )
	 )
   end

   fun {ShowAnswers Answers}
      {UL
       {List.mapInd Answers
	fun {$ I A}
	   'div'("Option: \"" b(A) "\"  "
		 a("(Remove this option)"
		   href:fun {$ S}
			   {S.set answers {RemoveNth Answers I}}
			   {EnterOptions S}
			end
		  )
		)
	end
       }
      }
   end
   
   fun {RemoveNth Xs I}
      {List.filterInd Xs fun {$ J _} J \= I end}
   end

   fun {Delete Session}
      'div'(h1("Delete polls")
	    {UL
	     {Map {Session.model allPolls(result:$)}
	      fun {$ Poll}
		 a("Delete \""#Poll.question#"\""
		   href:fun {$ S}
			   'div'("Really? "
				 a("Yes"
				   href:fun {$ S}
					   {Session.model deletePoll(Poll.id)}
					   {Delete Session}
					end
				  )
				 " "
				 a("No" href:Delete)
				)
			end
		  )
	      end
	     }
	    }	    
	   )	   
   end

   fun {MakeAdmin S}
      'div'(h1("Designate Admin")
	    {UL
	     {Map {S.model allNonAdmins(result:$)}
	      fun {$ user(login:L)}
		 a("User: "#L
		   href:fun {$ S}
			   {S.model makeAdmin(L)}
			   {MakeAdmin S}
			end
		  )
	      end
	     }
	    }
	   )
   end

   fun {IsAdmin S}
      User = {S.condGetShared user unit}
   in
      {CondSelect User isAdmin false}
   end
   
   fun {Before S Fun}
      if {IsAdmin S} then Fun
      else fun {$ Session} p("Permission denied") end
      end
   end

   fun {After S Doc}
      if {IsAdmin S} then
	 html(
	    head(title("Administrate polls")
		 style(type:"text/css"
		       css(a(':link') 'text-decoration':none)
		       css(a(':visited') 'text-decoration':none)
		       css(a(':active') 'text-decoration':none)
		       css(a(':hover') 'text-decoration':underline)
		       css(a(linkbar) margin:"5px" 'background-color':"#fff2f2")
		      ))
	    body(onLoad:JavaScriptCode.activateFirstForm
		 'div'(
		    h3("Administrate polls")
		    hr
		    Doc
		    hr
		    a("Create a poll"
		      href:url('functor':admin function:create) 'class':linkbar)
		    a("Delete a poll"
		      href:url('functor':admin function:delete) 'class':linkbar)
		    a("Designate an admin"
		      href:url('functor':admin function:makeAdmin) 'class':linkbar)
		    a("Leave admin area"
		      href:url('functor':'' function:showAll) 'class':linkbar)
		    )
		)
	    )
      else
	 html(body(Doc))
      end
   end
end
