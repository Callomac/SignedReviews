/* SAS code for the analysis in Fox, Charles (2021), Which peer reviewers voluntarily reveal their identity to authors? Insights into the consequences of open-identities peer review , Dryad, Dataset, https://doi.org/10.5061/dryad.8pk0p2np3 */
/* This is for the dataset including paired data */
/* Each row of the dataset is a single paper, with one set of columns for signed reviews and one set for unsighed reviews */

data Signed_Paired;
input Year WordCount_UnSigned SuggestedRefs_UnSigned RevSex_UnSigned$ ReviewScore_UnSigned 
		DaysToReview_UnSigned SuggestedReviewer_Unsigned Salute_Unsigned
		WordCount_Signed SuggestedRefs_Signed RevSex_Signed$ ReviewScore_Signed DaysToReview_Signed 
		SuggestedReviewer_Signed Salute_Signed
		RevisionInvited RevisionOrResubInvited;

Wordcount_Diff = WordCount_Signed - WordCount_UnSigned; 
SuggestedRefs_Diff = SuggestedRefs_Signed - SuggestedRefs_UnSigned;
ReviewScore_Diff = ReviewScore_Signed - ReviewScore_UnSigned;
DaysToReview_Diff = DaysToReview_Signed - DaysToReview_UnSigned;

SuggestedAnyRefs_Signed = 0; SuggestedAnyRefs_UnSigned = 0;
	If SuggestedRefs_Signed > 0 then SuggestedAnyRefs_Signed = 1;
	If SuggestedRefs_UnSigned > 0 then SuggestedAnyRefs_UnSigned = 1;
	SuggestedAnyRefs_Diff = SuggestedAnyRefs_Signed - SuggestedAnyRefs_UnSigned;

run;

proc univariate data=Signed_Paired; /* Non-parametric paired comparisons */
	var Wordcount_Diff SuggestedAnyRefs_Diff SuggestedRefs_Diff ReviewScore_Diff DaysToReview_Diff;
	run;
proc freq data=Signed_Paired; /* McNemar's test for author suggested reviewers as requested by reviewer*/;
		tables SuggestedReviewer_Signed*SuggestedReviewer_UnSigned /agree expected norow nocol nopercent; 
		run;

/* Paired comparison for author suggested reviewers */
data AuthorSuggested; set Signed_Paired;
	Suggested_Diff = SuggestedReviewer_Signed - SuggestedReviewer_Unsigned;
	If Suggested_Diff = 0 then delete; /* Restrict dataset to just papers where there is one suggested and one non-suggested */
	If Suggested_Diff = . then delete; run;
	proc sort data=AuthorSuggested; by Suggested_Diff; run;
	proc means data = AuthorSuggested mean; 
		var SuggestedReviewer_Signed SuggestedReviewer_Unsigned; run;
		proc univariate data=AuthorSuggested;
			var SuggestedReviewer_Signed SuggestedReviewer_Unsigned Suggested_Diff; run;
	
/* Paired analysis comparing salutations */
Data Salute; set Signed_Paired;
	Salute_Same = 0;
		If Salute_Signed = Salute_Unsigned then Salute_Same = 1; /* limit comparison to only papers for which the salutations differ */
		If Salute_Signed = 'None' then Salute_Same = .;
		If Salute_Unsigned = 'None' then Salute_Same = .;
		If Salute_Same = . then delete; 
		If Salute_Same = 1 then delete; run;
	/* compare Dr vs Prof */ /* Dr = 0, Prof = 1 */
	Data Salute2; set Salute;
		If Salute_Signed = 'Other' then delete;
		If Salute_Unsigned = 'Other' then delete;
		If Salute_Signed = 'Professor' then Salutation_Signed = 1;
		If Salute_Unsigned = 'Professor' then Salutation_UnSigned = 1;
		If Salute_Signed = 'Dr' then Salutation_Signed = 0;
		If Salute_Unsigned = 'Dr' then Salutation_UnSigned = 0;
		Salutation_Diff = Salutation_Signed - Salutation_Unsigned;
		If Salutation_Diff = 0 then delete;  
		If Salutation_Diff = -1 then Salutation_Diff = 0;  run;
	proc univariate data=Salute2; /* non-parametric comparison of slutations */ 
		var Salutation_Diff;
		run;
