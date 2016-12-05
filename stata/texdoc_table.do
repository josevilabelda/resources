*===============================================================================
* Name: 		exports_comparison.do
* Description:	Compare exports from F29 (SII) and from customs data
* Notes: 		This do-file looks best with indentations set to 4 spaces. 
* Author:		Alvaro Carril (acarril@povertyactionlab.org)
*===============================================================================

*-------------------------------------------------------------------------------
* Initial set up
*-------------------------------------------------------------------------------
version 14
set more off
clear all
cd /nfs/projects/t/tpricing
use output/TPdata_firm, clear
local dir docs/exports_comparison/figs_tabs

local plots_of_means 0
local histograms 0
local summarystats 1



g exports_diff = DUSexports - f29c20
gen exports_max = max(f29c20, DUSexports)

* Create variable with max of exports (F29 or DUS)
lab var exports_max "Exports (max)"

* Difference beween exports masure as proportion of max:
gen exports_diff_prop = exports_diff / exports_max
label var exports_diff_prop "(Customs-F29)/Max)"

* Label affiliate dummy
label var affiliate "affiliation status"
label define affiliate 0 "Non-affiliates" 1 "Affiliates"
label values affiliate affiliate


if `plots_of_means' == 1 {

	* Tabulate exports by year, affiliation status

	* Plot annual mean by affiliation status
	graph bar (mean) f29c20 DUSexports, ///
		over(year) legend(order(1 "F29" 2 "Customs") cols(2)) by(affiliate)
	graph export `dir'/exports_mean_yearly_byaffiliation.pdf, replace

	* Plot difference of annual means by affiliation status
	label var exports_diff "Difference (F29-Customs)"
	graph bar (mean) exports_diff, ///
		over(year) ytitle(Difference in exports (Customs - F29)) by(affiliate)
	graph export `dir'/exports_meandiff_yearly_byaffiliation.pdf, replace

	* Plot probability of declaring exports
	g f29c20_bin = (f29c20 > 0)
	g DUSexports_bin = (DUSexports > 0)
	graph bar (mean) f29c20_bin (mean) DUSexports_bin, ///
		over(year) legend(order(1 "F29" 2 "Customs") cols(2)) by(affiliate)
	graph export `dir'/exports_prob_yearly_byaffiliation.pdf, replace
		
	* Plot probability of declaring only one form
	g exports_f29_discrepancy_bin = (f29c20 > 0 & DUSexports==0)
	g exports_DUS_discrepancy_bin = (f29c20 ==0 & DUSexports >0)
	graph bar (mean) exports_f29_discrepancy_bin exports_DUS_discrepancy_bin, ///
		over(year) ytitle("") legend(order(1 "F29" 2 "Customs") cols(2)) by(affiliate)
	graph export `dir'/exports_probdiscrepancy_yearly_byaffiliation.pdf, replace

}



/* About Stata wishker plots:
The median is represented by a line subdividing the box. 
The length of the box thus represents the interquartile range (IQR)
One whisker extends to include all data points within 1.5 IQR of the upper/lower quartile and stops at the largest/smallest such value
Any data points beyond the whiskers are shown individually
*/
*graph box exports_diff_prop, over(affiliation)
*graph box exports_diff_prop, over(taxhaven)
*graph box exports_diff_prop if psw1_1to1==1, over(affiliate) 
*graph box exports_diff_prop if psw4_1to1==1, over(taxhaven)

if `histograms' == 1 {

	*define subsamples, full sample:	
	local A "!missing(id)" //i.e. all firms here
	local B "affiliate == 1"
	local C "affiliate == 0"
	local D "affiliate == 1 & taxhaven == 1"
	local E "affiliate == 1 & taxhaven == 0"
	
	* histograms for full sample
	mdesc exports_diff_prop if `A'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `A'
	distinct id if !missing(exports_diff_prop) & `A'
	twoway histogram exports_diff_prop if `A', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_full_all.pdf, replace

	mdesc exports_diff_prop if `B'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `B'
	distinct id if !missing(exports_diff_prop) & `B'
	twoway histogram exports_diff_prop if `B', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_full_affil.pdf, replace

	mdesc exports_diff_prop if `C'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `C'
	distinct id if !missing(exports_diff_prop) & `C'
	twoway histogram exports_diff_prop if `C', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_full_nonaffil.pdf, replace

	mdesc exports_diff_prop if `D'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `D'
	distinct id if !missing(exports_diff_prop) & `D'	
	twoway histogram exports_diff_prop if `D', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_full_taxhaven.pdf, replace

	mdesc exports_diff_prop if `E'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `E'
	distinct id if !missing(exports_diff_prop) & `E'
	twoway histogram exports_diff_prop if `E', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_full_nontaxhaven.pdf, replace

	
	*define subsamples, matched sample:	
	local F "affiliate == 1 & psw1_1to1==1"
	local G "affiliate == 0 & psw1_1to1==1"
	local H "affiliate == 1 & taxhaven == 1 & psw4_1to1==1"
	local I "affiliate == 1 & taxhaven == 0 & psw4_1to1==1"
	
	* histograms for matched samples
	mdesc exports_diff_prop if `F'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `F'
	distinct id if !missing(exports_diff_prop) & `F'
	twoway histogram exports_diff_prop if `F', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_matched_affil.pdf, replace

	mdesc exports_diff_prop if `G'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `G'
	distinct id if !missing(exports_diff_prop) & `G'
	twoway histogram exports_diff_prop if `G', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_matched_nonaffil.pdf, replace

	mdesc exports_diff_prop if `H'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `H'
	distinct id if !missing(exports_diff_prop) & `H'
	twoway histogram exports_diff_prop if `H', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_matched_taxhaven.pdf, replace

	mdesc exports_diff_prop if `I'
	local percentmiss: di %2.1fc  `r(percent)'
	count if !missing(exports_diff_prop) & `I'
	distinct id if !missing(exports_diff_prop) & `I'
	twoway histogram exports_diff_prop if `I', percent xlabel(-1(0.1)1) width(0.1) start(-1.05) subtitle(`r(N)' observations and `r(ndistinct)' firms - `percentmiss'% missing)
	graph export `dir'/exports_diff_prop_matched_nontaxhaven.pdf, replace

}


* summarize detail tables

if `summarystats' == 1 {

	* create vars for each subsample
	gen exports_full_all = exports_diff_prop
	gen exports_full_aff = exports_diff_prop if affiliate == 1
	gen exports_full_noaff = exports_diff_prop if affiliate == 0
	gen exports_full_th = exports_diff_prop if affiliate == 1 & taxhaven == 1
	gen exports_full_noth = exports_diff_prop if affiliate == 1 & taxhaven == 0

	gen exports_match_aff = exports_diff_prop if affiliate == 1 & psw1_1to1==1
	gen exports_match_noaff = exports_diff_prop if affiliate == 0 & psw1_1to1==1
	gen exports_match_th = exports_diff_prop if affiliate == 1 & taxhaven == 1 & psw4_1to1==1
	gen exports_match_noth = exports_diff_prop if affiliate == 1 & taxhaven == 0 & psw4_1to1==1

	label var exports_full_all "All" 
	label var exports_full_aff "Affil."
	label var exports_match_aff "Affil."
	label var exports_full_noaff "Non-affil."
	label var exports_match_noaff "Non-affil."
	label var exports_full_th "TH affil."
	label var exports_match_th "TH affil."
	label var exports_full_noth "Non-TH affil"
	label var exports_match_noth "Non-TH affil"

	*full sample table
	estpost tabstat exports_full_all exports_full_aff /// 
		exports_full_noaff exports_full_th ///
		exports_full_noth, ///
		statistics(mean max min sd p1 p5 p10 p25 median p75 p90 p95 p99 count)
	
	*esttab, cells("exports_full_all(%9.3f)) exports_full_aff exports_full_noaff exports_full_th exports_full_noth") noobs nomtitle nonumber
	esttab using `dir'/summarystats_exports_diff_prop_full.tex, cells("exports_full_all(fmt(%9.3f)) exports_full_aff exports_full_noaff exports_full_th exports_full_noth") noobs nonumber nomtitles booktabs replace collabels("All" "Affil." "Non-affil." "TH affil." "Non-TH affil")
	
	
	*matched sample table
	estpost tabstat exports_match_aff ///
		exports_match_noaff exports_match_th ///
		exports_match_noth, ///
		statistics(mean max min sd p1 p5 p10 p25 median p75 p90 p95 p99 count) ///
		columns(variables) 
	
	*esttab, cells("exports_match_aff(fmt(%9.3f)) exports_match_noaff exports_match_th exports_match_noth") noobs nomtitle nonumber
	esttab using `dir'/summarystats_exports_diff_prop_matched.tex, cells("exports_match_aff(fmt(%9.3f)) exports_match_noaff exports_match_th exports_match_noth") noobs nonumber nomtitles booktabs replace collabels("Affil." "Non-affil." "TH affil." "Non-TH affil")


*Additional summary stats: 
	
	* Row contents:
	*  1 number of firms
	*  2 number of obs
	*  3 number of obs with positive exports
	*  4 Prop. of obs with positive exports
	*  5 Mean of DUS
	*  6 Mean of F29
	*  7 Mean of DUS if DUS>0
	*  8 Mean of F29 if F29>0
	*  9 Prop. reporting only positive in DUS
	*  10 Prop. reporting only positive in F29
	*  11 Prop. where DUS is greater than 0.1*F29
	*  12 Prop. where F29 is greater than 0.1*DUS
	local 1_name "Firms"
	local 2_name "Observations"
	local 3_name "Obs. with exports (any)"
	local 4_name "Prop. with exports (any)"
	local 5_name "Mean of DUS exports"
	local 6_name "Mean of F29 exports"
	local 7_name "Mean of DUS if DUS $>$ 0"
	local 8_name "Mean of F29 if F29 $>$ 0"
	local 9_name "Prop. positive only in DUS"
	local 10_name "Prop. positive only in F29"
	local 11_name "Prop. DUS $>$ 0.1 $\times$ F29"
	local 12_name "Prop. F29 $>$ 0.1 $\times$ DUS"
	

	*define subsamples, full sample:	
	local A "!missing(id)" //i.e. all firms here
	local B "affiliate == 1"
	local C "affiliate == 0"
	local D "affiliate == 1 & taxhaven == 1"
	local E "affiliate == 1 & taxhaven == 0"
	
	*define subsamples, matched sample:	
	local F "affiliate == 1 & psw1_1to1==1"
	local G "affiliate == 0 & psw1_1to1==1"
	local H "affiliate == 1 & taxhaven == 1 & psw4_1to1==1"
	local I "affiliate == 1 & taxhaven == 0 & psw4_1to1==1"

	foreach subsample in A B C D E F G H I {
		
		distinct id if ``subsample'' //double local
		local 1_`subsample': di %12.0fc  `r(ndistinct)' //simple local
		
		count if ``subsample'' //double local
		local 2_`subsample': di %12.0fc `r(N)' //simple local
		
		count if ``subsample'' & exports_max>0 & !missing(exports_max) //double local
		local 3_`subsample': di %12.0fc `r(N)' //simple local
		
		count if ``subsample'' & exports_max>0 & !missing(exports_max) //double local
		local numerator `r(N)' 
		count if ``subsample'' //double local
		local denominator `r(N)' 
		local 4_`subsample' = `numerator' / `denominator'
		local 4_`subsample': di %12.3fc `4_`subsample''
		
		sum DUSexports if ``subsample'', meanonly
		local 5_`subsample': di %12.0fc  `r(mean)'

		sum f29c20 if ``subsample'', meanonly
		local 6_`subsample': di %12.0fc  `r(mean)'
		
		sum DUSexports if ``subsample'' & DUSexports>0 & !missing(DUSexports), meanonly
		local 7_`subsample': di %12.0fc  `r(mean)'

		sum f29c20 if ``subsample'' & f29c20>0 & !missing(f29c20), meanonly
		local 8_`subsample': di %12.0fc  `r(mean)'		
		
		cap gen exports_DUS_discrepancy_bin = (f29c20 ==0 & DUSexports >0)
		sum exports_DUS_discrepancy_bin if ``subsample''
		local 9_`subsample': di %12.3fc  `r(mean)'
		
		cap gen exports_f29_discrepancy_bin = (f29c20 > 0 & DUSexports==0)
		sum exports_f29_discrepancy_bin if ``subsample''
		local 10_`subsample': di %12.3fc  `r(mean)'

		cap gen exports_DUS_gr_01_F29 = (DUSexports > 0.1*f29c20 & !missing(DUSexports))
		sum exports_DUS_gr_01_F29 if ``subsample''
		local 11_`subsample': di %12.3fc  `r(mean)'
		
		cap gen exports_F29_gr_01_DUS = (f29c20 > 0.1*DUSexports & !missing(f29c20))
		sum exports_F29_gr_01_DUS if ``subsample''
		local 12_`subsample': di %12.3fc  `r(mean)'
	}
	
	*Full sample table:
	texdoc init `dir'\summarystats_counts_full.tex, replace
		tex \begin{tabular}{cccccc}
		tex \hline 
		tex & All & Affil. & Non-affil. & TH affil. & Non-TH affil. \\  
		tex \hline
		forvalues row = 1/12 {
			tex ``row'_name' & ``row'_A' &  ``row'_B' &  ``row'_C' &  ``row'_D' &  ``row'_E' \\ 
		}
		tex \hline 
		tex \end{tabular} 
	
	texdoc close

	*Matched sample table:
	texdoc init `dir'\summarystats_counts_matched.tex, replace
		tex \begin{tabular}{ccccc}
		tex \hline 
		tex & Affil. & Non-affil. & TH affil. & Non-TH affil. \\  
		tex \hline
		forvalues row = 1/12 {
			tex ``row'_name' & ``row'_F' &  ``row'_G' &  ``row'_H' &  ``row'_I' \\ 
		}
		tex \hline 
		tex \end{tabular} 
	texdoc close


}



