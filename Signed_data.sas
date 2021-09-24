/* SAS code for the analysis in Fox, Charles (2021), Which peer reviewers voluntarily reveal their identity to authors? Insights into the consequences of open-identities peer review , Dryad, Dataset, https://doi.org/10.5061/dryad.8pk0p2np3 */
/* This is for the dataset for the large unpaired dataset */

data Signed;
input Sort msID Year Signed RevSex$ ReviewScore RevisionInvited RevisionOrResubInvited
	RevCountry$ DaysToReview Salute$;
run;

/* Does signing differ by Gender? */
Data Signed_A; Set Signed;
	If RevSex = '.' then delete; 
	If RevSex = ' ' then delete; run;
proc sort data=signed_A; by RevSex year; run;
	proc means data=signed_A mean; /* Mean per year */
		var Signed; by RevSex year; output out=SignedByYear mean=signed; run; /* mean averaged across years */
		Proc means data=SignedByYear mean stderr; Var Signed; by RevSex; run; 
	proc logistic descending data=signed_A;
		class RevSex; model Signed = Year RevSex; /* Interaction deleted because it was non-significant*/
			/* I included year as a continuous variable, but the results are largely unchaged if Year is treated as a class variable */
		contrast 'EarlyVLate' year -1 -1 -1 1 1 1; run;

/* Does signing differ by salutation? */
Data Signed_Prof_v_Doc; Set Signed;
	If Salute = 'Mr' then delete; /* Deleting salutatiuons not consider. Sample sizes are low for these salutations and many are out of date (people become Dr or Professor after creating their accounts but before reviewing for the journal */
	If Salute = 'Mrs' then delete; 
	If Salute = 'Mrs.' then delete; 
	If Salute = 'Miss' then delete; 
	If Salute = 'Ms' then delete; 
	If Salute = 'None' then delete; 
	If Salute = '.' then delete; run;
proc sort data=Signed_Prof_v_Doc; by Salute year; run;
	proc means data=Signed_Prof_v_Doc mean; 
		var Signed; by Salute year; output out=SignedByYearSalute mean=signed; run; /* Mean per year */
		Proc means data=SignedByYearSalute mean stderr; Var Signed; by Salute; run; /* Mean averaged across years */
	proc logistic descending data=Signed_Prof_v_Doc; /* Do "Professors" sign more than "Dr" */
		class Salute; model Signed = Year Salute; Run; /* Interaction ns and thus deleted */
		proc logistic descending data=Signed_Prof_v_Doc; /* Does the salutation explain the gender difference */
			class Salute RevSex; model Signed = Year Salute RevSex; Run; 

/* Gender difference in the proportion of reviewers that signed at least one review */
Data Signed_A; Set Signed; /* Delete missing data */
	If RevSex = '.' then delete; 
	If RevSex = ' ' then delete; run;
proc sort data=signed_A; by RevSex ReviewerID; run; /* reviewerIDs are not included in the published dataset */
	proc means data=signed_A mean noprint; by RevSex ReviewerID; 
		var Signed; output out=MeanByReviewer mean=ProportionSigned; run; /* Proportion of reviews signed per reviewer */
	data MeanByReviewer; set MeanByReviewer; /* Scoring reviewers as having signed at least one review, or none */
		if ProportionSigned > 0 then SignedSome = 1;
		if ProportionSigned = 0 then SignedSome = 0; run;
		/* Does signing differ by sex? */
			proc sort data=MeanByReviewer; by RevSex; run;
				proc means data=MeanByReviewer; 
					var SignedSome; by RevSex; run;
				proc logistic descending data=MeanByReviewer; 
					class RevSex;
					model SignedSome = RevSex; Run; 


/* Does ReviewScore differ by signing? */
proc sort data=signed; by Year Signed; run; 
	proc means data=Signed mean stderr; 
		var ReviewScore; by Year Signed; run;
	proc glm data=signed; /* ReviewScore is the mean of the reviewer scores given by all reviewers of a paper, so is a continuous varible, but not well behaved. This analysis is thus followed by a paired analysis, presented in the other SAS file (that included all paired analyses) */
		class Signed;
		model ReviewScore = Year Signed; 
			LSMeans Signed / stderr; Run; 


/* Does signing predict editor decisions? */
proc sort data=signed; by msID year RevisionInvited RevOrResubInvited; run;
proc means data=Signed mean max noprint; /* condense data to one line per paper */
		var Signed ReviewScore; by msID year RevisionInvited RevOrResubInvited; 
			/* mean signed = proportion signed; max = were any signed (yes = 1) */
	Output out=OneLinePerPaper mean=ProportionSigned ReviewScore max=AtLeastOneSigned MaxReviewScore; run;
		proc sort data=OneLinePerPaper; by AtLeastOneSigned year; run;
			proc means data=OneLinePerPaper mean noprint; /* Average per year */
				var RevisionInvited RevOrResubInvited; by AtLeastOneSigned Year; 
				Output out=OneLinePerPaper1 mean=meanRevisionInvited meanRevOrResubInvited; run;
			proc means data=OneLinePerPaper1 mean stderr; /*Average across years */
					var meanRevisionInvited meanRevOrResubInvited; by AtLeastOneSigned; run;
	proc logistic data=OneLinePerPaper descending; /* Does signed predict editor decisions? */
		class AtLeastOneSigned; model RevisionInvited = Year AtLeastOneSigned; run;
		proc logistic data=OneLinePerPaper descending; /* Does signing predict editor decisions after accounting for review scores? */
			class AtLeastOneSigned; model RevisionInvited = Year AtLeastOneSigned ReviewScore; run;
	proc logistic data=OneLinePerPaper descending;
		class AtLeastOneSigned;
		model RevOrResubInvited = Year AtLeastOneSigned; run;

/* Three additional analysis sections have been deleted because the data (reviewer identities and locations) cannot be shared - they violate Dryad and IRB policies */
/* The deleted sections were either calculating means or comparing among geographic regions, with models very similar to those presented above */

