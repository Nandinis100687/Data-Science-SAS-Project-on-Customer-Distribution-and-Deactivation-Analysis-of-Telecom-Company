libname Nandini "E:\Metro College\SAS\day1 library";

DATA Nandini.Telcm;
INFILE 'E:\Metro College\SAS\Advanced sas\New_Wireless_Fixed.txt' truncover;
INPUT Acctno: $ 15. Actdt:mmddyy10. Deactdt:mmddyy10. @36 DeactReason: $ 4. @48 GoodCredit  @58 RatePlan: $ 2. @65 DealerType: $ 2. @72 Age @78 Province: $ 2. @86 Sales: dollar10.2;
format Actdt mmddyy10. Deactdt mmddyy10. Sales dollar10.2 ;
RUN;
/*values from next column was getting merged with Deact reson column where missing so replaced with blank*/
proc sql;
 update Nandini.Telcm
 set DeactReason = " "
where DeactReason in ('0', '1')
;
quit;
/*values from next column was getting merged with Province  column where missing so replaced with blank*/
proc sql;
update Nandini.Telcm
 set Province = " "
where Province not in ('AB','BC','NS','ON','QC');
quit;

proc contents Data=Nandini.telcm;run;
proc print Data=Nandini.Telcm (obs=40);run;

proc means Data=Nandini.Telcm;run;

/*proc sql;
select * from Nandini.Telcm
where Age>99;
run;*/

/*to CHeck total number of unique Account no which is same as total observations.*/
proc sql;
select count(distinct(Acctno))as Total_Actno
from Nandini.Telcm;
quit;

/*Distribution of Categorical Variables*/
proc freq Data=Nandini.Telcm;
table DeactReason DealerType Province RatePlan/ missing;
run;
/*Visualisation of Categorical Variables*/
title"UNIVARIATE ANALYSIS";
title"Bar Chart showing classification of Deact Reason";
proc sgplot data=Nandini.Telcm;
vbar DeactReason/filltype=gradiant groupdisplay=cluster datalabel;
run;
title;

title"UNIVARIATE ANALYSIS";
title"Bar Chart showing classification of Dealer Type";
proc sgplot data=Nandini.Telcm;
vbar DealerType/filltype=gradiant groupdisplay=cluster datalabel;
run;
title;
run;

title"UNIVARIATE ANALYSIS";
title"Pie Chart showing classification of Province";
proc gchart data=Nandini.Telcm;
pie Province/missing discrete value= inside percent=inside;
goption colors=(white,Cyan,Pink, orange,Yellow,green);
run;
title;
run;

title"UNIVARIATE ANALYSIS";
title"Pie Chart showing classification of RatePlan";
proc gchart data=Nandini.Telcm;
pie Rateplan/discrete value= inside percent=inside;
goption colors=(Cyan,Pink, orange);
run;
title;
run;

/*Good Credit Classification*/
proc freq Data=Nandini.Telcm;
table GoodCredit;run;

title"UNIVARIATE ANALYSIS";
title"Bar Chart showing classification of Good Credit";
proc sgplot data=Nandini.Telcm;
vbar GoodCredit/filltype=gradiant groupdisplay=cluster datalabel;
run;
title;

/*Distribution of Numeric Values*/
proc means data=Nandini.Telcm n nmiss var std cv clm mean sum min max maxdec=2;run;
proc means Data=Nandini.Telcm n nmiss var std cv clm mean sum min max maxdec=2;
var Actdt Deactdt;
run;

proc univariate Data=Nandini.telcm normal;
var Actdt Deactdt;
qqplot /normal (mu=est sigma=est);
run;

proc sort data=Nandini.telcm out=Nandini.Telm1 nodupkey;
by _all_;run;
proc contents Data=Nandini.telm1;run;

/*Latest Activation Date*/
title;
proc sort Data=Nandini.Telcm out=Nandini.Act  nodupkey;
by descending Actdt;
run;
proc print Data=Nandini.Act (obs=1);
format Actdt mmddyy10.;
run;
/*Latest Deactivation Date*/
proc sort Data=Nandini.Telcm out=Nandini.Deact nodupkey;
by descending Deactdt;
run;
proc print Data=Nandini.Deact (obs=1);
format Deactdt mmddyy10.;
run;

/*Age Distribution*/
proc means Data=Nandini.Telcm n nmiss var std cv clm mean sum min max qrange maxdec =2;
var Age;
run;

proc univariate Data=Nandini.Telcm normal plot;
var Age;
qqplot /normal (mu=est sigma=est);
run;
/*Visualisation Age */
TITLE'BOX PLOT';
proc sgplot data = Nandini.Telcm;;
vBOX Age ;
run;

/*Sales Classification*/
proc means Data=Nandini.Telcm n nmiss var std cv clm mean sum min max Q1 Q3 qrange maxdec =2;
var Sales;
run;

proc univariate Data=Nandini.Telcm normal plot;
var Sales;
qqplot /normal (mu=est sigma=est);
run;
/*Visualisation Age */
TITLE'BOX PLOT';
proc sgplot data = Nandini.Telcm;;
vBOX sales ;
run;


/*1.2 What are the age and province distributions of active and deactivated customers? */
/*Distribution of Active and No active Customers among Ages using Proc Univariate*/

Data Nandini.Status;
set Nandini.Telcm;
length Status $ 12.;
If Deactdt eq . then Status="Active";
else if Deactdt ne . then Status="Deactivated";
proc print Data=Nandini.status (obs=20);run;

proc means Data=Nandini.Status n min max std mean cv clm maxdec=2;
class Status/missing;
var Age;
run;

proc univariate Data=Nandini.Status normal plot;
var Age;
Class Status;
qqplot /normal (mu=est sigma=est);
run;
/*Ho=  Age  is normally distributed .
H1- Age is not normally distributed .
Age in Active Customers -P value<0.05- We reject Null Hypothesis
Age in Deactivated Customers -P value<0.05- We reject Null Hypothesis
/*For both status p value <0.05 . so we reject Null Hypotheis of Age distribution being normal in bth status*/
/*However as per CLT since each group size is >30 we consider it as normal data*/

/*Equality of variance*/
proc glm data=Nandini.Status;
class Status;
model Age = Status;
means Status / hovtest=levene(type=abs) welch;
run;

/*Ho= All groups of Equal variances
H1= All groups do not have equal variances

Since P value 0.6795 is > 0.05. we Fail to reject null hypothesis and conclude that variance of sales in 
both categories of Goodcredit is equal*/

/*Proving Sales is same in both status*/
/*Ho- Mean of sales is same in both categories of Goodcredit
H1- Mean of sales is not same in both categories of Goodcredit */
proc ttest Data=Nandini.Status;
Var Age;
Class Status;
run;

/*Distribution of Active and No active Customers among provinces using contingency table*/
proc freq Data=Nandini.Status;
table Province*Status/missing chisq norow nocol;
run;
title"Comparison between Province and Status";
proc SGplot Data=Nandini.Status;
vbar Province/group=status filltype=Gradiant groupdisplay=cluster datalabel;
run;
/*H0= There is no association between Province and Account Status
H1- There is association between Province and DeactReason

Since P value in CHisq test is >0.05. We Failed to reject null Hypothesis. Means There is no association between Province and
CUstomers activation and Deactivation.*/

/*Age Vs province- Mean of Age is same in all provinces
Ho- Mean of Age is Equal in all provinces
H1- Mean of Age is not equal in all provinces*/

/*Age Vs Province Descriptive Analysis*/
proc means Data=Nandini.Telcm n min max std mean cv clm maxdec=2;
var Age;
class Province/missing;
run;

/*Age Vs. province Normality Test*/
proc univariate Data=Nandini.Telcm normal plot;
var Age;
class Province;
qqplot /normal (mu=est sigma=est);
run;
/*For all Province p value <0.05 . so we reject Null Hypotheis of Age distribution being normal among all provinces*/
/*However as per CLT since each group size is >30 we consider it as normal data*/

/*CHecking Equality of Variances */
proc glm data=Nandini.Telcm;
class Province;
model Age = Province;
means Province / hovtest=levene(type=abs) welch;
run;

*From group box plots We can see that we don't have major outliers and
Because of p-value of Levene's Test=0.0.097 >0.05 we fail to reject null hypotheses so we can consider that all
groups have almost equal variance so we should read p-value of the standard one-way ANOVA results;

/*H0= Means of age are equal across all provinces
H1- Mean of age are not equal across all provinces*/
PROC ANOVA DATA = Nandini.Telcm;
 CLASS Province;
 MODEL Age = Province;
 MEANS Province;
TITLE "Age distribution across Province";
RUN;
QUIT;

PROC ANOVA DATA = Nandini.Telcm;
 CLASS Province;
 MODEL Age = Province;
 MEANS Province/scheffe;
TITLE "Age distribution across Province";
RUN;
QUIT;

/*Since P value 0.8697>0.05 in One way Anova we failed to reject Null Hypotheis.Hense conlude that Age is eqyally distributed 
across all provinces*/

/*1.3 Segment the customers based on age, province, and sales amount:
Sales segment: < $100, $100-$500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
*/

proc format;
value Agegroup
low-20='<20'
21- 40='21-40'
41-60='41-60'
61-High='60 and above';
run;

proc format;
value SalesGroup
low-100='<$100'
101- 500='$100-$500'
501-800='$500-$800'
801-High='$800 and above'
;
RUN;

Title"Age Segmentation";
proc print Data=Nandini.Telcm (obs=20);
format Age Agegroup.;run;
title;
Title"Sales Segmentation";
proc print Data=Nandini.Telcm (obs=20);
format Sales SalesGroup.;run;
title;
Title"Province Segmentation";
Proc freq Data=Nandini.Telcm;
table Province;run;

Data Nandini.Telcm1;
set Nandini.Telcm;
Agesegment=Age;
Salessegment=Sales;
format Agesegment Agegroup. Salessegment SalesGroup.;
proc print Data=Nandini.Telcm1 (obs=20);
run;

proc contents Data=Nandini.Telcm1;run;
/*Customer Segemetation based on Province, Agegroup and Sales group*/
proc freq Data=Nandini.Telcm1;
table Province Agesegment Salessegment/missing;
run;
title;

/*1.4 1)Calculate the tenure in days for each account and give its simple statistics.*/

Title"Latest Activation and Deactivation Dates";
proc sql;
Create table Nandini.Dates as
select max(Actdt) as Latest_Activation_Date,
		max(Deactdt) as Latest_Deactivation_Date
from Nandini.Telcm;
run;
proc print Data=Nandini.Dates;
format Latest_Activation_Date Latest_Deactivation_Date mmddyy10.;run;
title;

Data Nandini.Tenure;
set Nandini.Telcm;
d1="20JAN2001"D;
if Deactdt eq . then Tenuredays=intck('day', Actdt, D1);
if Deactdt ne . then Tenuredays=intck('day', Actdt, Deactdt);
RUN; 
PROC PRINT DATA=Nandini.Tenure (obs=20);
FORMAT D1 DATE9.;
RUN;

proc means Data=Nandini.Tenure maxdec=2;
var Tenuredays;run;

/*2) Calculate the number of accounts deactivated for each month.*/

Data Nandini.Deact;
set Nandini.Telcm;
Month=month(Deactdt);
format Deactdt date9.;
proc print Data=Nandini.Deact (OBS=20);run;

proc sql;
select month,count(Acctno) as Total_Deactivated
from Nandini.Deact
where not missing(Deactdt)
group by Month
order by Month
;
quit;

proc sql;
select count(actdt)as Same_Day_Deactivation from Nandini.Telcm
where actdt=deactdt
;
quit;


/*3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.
*/

Data Nandini.Status_Tenure;
set Nandini.Tenure;
length Acct_Status $ 12. Tenure $ 25.;
If Deactdt eq . then Acct_Status="Active";
else if Deactdt ne . then Acct_Status="Deactivated";
if Tenuredays <30 then Tenure="0-30 Days";
else if Tenuredays >=31 and Tenuredays<60 then Tenure="31--60Days";
else if Tenuredays >=61 and Tenuredays<366 then Tenure="61 days --One Year";
else Tenure="Over One Year";
run;
proc print Data=Nandini.Status_Tenure (obs=20);run; 

proc freq Data=Nandini.Status_Tenure;
table Acct_Status Tenure/missing;run;

/*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”-chi sq
*/

/*Descriptive ANalysis of Good Credit , Rateplan,DealerType as per Tenure segments*/

/*Tenure segments vs GoodCrdit*/

proc freq Data=Nandini.Status_Tenure;
table Tenure*GoodCredit/Missing chisq norow nocol;
run;
proc freq Data=Nandini.Status;
table Status*goodcredit/missing;
run;
title"Comparison between Tenure and Good Credit ";
proc SGplot Data=Nandini.Status_tenure;
vbar Tenure/group=GoodCredit filltype=Gradient groupdisplay=cluster datalabel;
run;
/*Ho- There is no association between Tenuresegements and GoodCredit
H1- There is an association between Tenure Segements and Good Credit 

Since P value in Chi sq test is <0.05 - we reject Null Hypotheis and conclude that the is statistically significant asscociation 
between Tenure Segements and Good Credit. In other terms we can say that customer who has greater tenure are likely to have good credit*/

/*Tenure segments vs Rateplan*/
proc freq Data=Nandini.Status_Tenure;
table Tenure*Rateplan/Missing chisq norow nocol;
run;
proc freq Data=Nandini.Status;
table Status*Rateplan/missing;
run;

title"Comparison Between Tenure and Rateplan";
proc sgplot Data=Nandini.Status_tenure;
vbar Tenure/group=Rateplan filltype=Gradient Groupdisplay=cluster datalabel;
run;

/*Ho- There is no association between Tenuresegements and Rateplan
H1- There is an association between Tenure Segements and Rateplan 

Since P value in Chi sq test is <0.05 - we reject Null Hypotheis and conclude that there is statistically significant asscociation 
between Tenure Segements and Rateplan. 
In other terms we can say that customers with Plan 1 are having greater tenure also has greater
active customer base and churn nearer to minimum.However churn is minimum for Rateplan 2. 
Rate plan 3 has max churn So we can say Plan 1 is better than other 2*/

/*Tenure segments vs DealerType*/
proc freq Data=Nandini.Status_Tenure;
table Tenure*DealerType/Missing chisq norow nocol;
run;
proc freq Data=Nandini.Status;
table Status*Dealertype/missing norow nocol;
run;
Title"Comparison Between Tenure and Dealer Type";
Proc sgplot Data=Nandini.Status_Tenure;
vbar Tenure/group=DealerType filltype=Gradient 
Groupdisplay=cluster datalabel;
run;


/*Ho- There is no association between Tenuresegements and DealerType
H1- There is an association between Tenure Segements and DealerType 

Since P value in Chi sq test is <0.05 - we reject Null Hypotheis and conclude that there is statistically significant asscociation 
between Tenure Segements and Dealertype. 
In other terms we can say that DealerType A1 is having more active customer base .however customer churn is almost equal for 
all dealer types
So we can say Dealertype A1 is better than other 3*/

/*5) Is there any association between the account status and the tenure segments?
Could you find a better tenure segmentation strategy that is more associated
with the account status?
*/
proc freq Data=Nandini.Status_tenure;
table acct_Status*Tenure/chisq missing norow nocol;
run;

proc freq Data=Nandini.Status_tenure;
table acct_Status*Tenure/chisq missing norow nocol out=Nandini.org;
run;
proc print data=nandini.org;run;

Title"Comparison Between Tenure and account Status";
Proc sgplot Data=Nandini.Status_Tenure;
vbar Tenure/Group=acct_Status filltype=Gradient
Groupdisplay=CLuster datalabel;
run;

proc sgplot Data=Nandini.org;
where acct_status="Deactivated";
series x=tenure y= count/markers;
xaxis label="Tenure";
yaxis label="Deactivated";
run;

/*Ho- There is no association between Tenuresegements and Account Status
H1- There is an association between Tenure Segements and Account Status 

Since P value in Chi sq test is <0.05 - we reject Null Hypotheis and conclude that there is statistically significant asscociation 
between Tenure Segements and Acccount Status.
In other words customer that have tenure greater than 60 days are still active .*/

/*Alternate tenure strateagy*/
Data Nandini.AltTenure;
set Nandini.Status_Tenure;
length AltTenure $ 20.;
if Tenuredays <30 then AltTenure="1 month and less";
else if Tenuredays >=31 and Tenuredays<60 then AltTenure="2months";
else if Tenuredays >=61 and Tenuredays<90 then AltTenure="3 months";
else if Tenuredays >=91 and Tenuredays<180 then AltTenure="3 to 6 months";
else if Tenuredays >=181 and Tenuredays<366 then AltTenure="6Months-1 yr";
else AltTenure="year and above";
run;
proc print Data=Nandini.AltTenure (obs=20);run;

proc freq Data=Nandini.AltTenure ;
table acct_Status*AltTenure/chisq missing norow nocol;
run;


proc freq Data=Nandini.AltTenure ;
table acct_Status*AltTenure/chisq missing norow nocol out=Nandini.freq;
run;
proc print Data=Nandini.freq;run;

proc sgplot Data=Nandini.freq;
where acct_status="Deactivated";
series x=Alttenure y= count/markers;
xaxis label="Tenure";
yaxis label="Deactivated";
run;

/*Greater number of Active customers have tenure more than one year. The trend shows that
number of active customers was statble in first 2 months . in 3rd month it reduced but after 3rd month count went on increasing.
customer churn was less in 2nd and 3rd month than 1st.but between 3 month to 1 year churn increased a bit. but after
one year churn reduced again.
*/

/*6) Does the Sales amount differ among different account statuses, GoodCredit, and
customer age segments?

descriptive analysis of sales class Account sttaus, good credit and age segments*/


Data Nandini.Sales;
set Nandini.Status;
Agesegment=Age;
format Agesegment Agegroup.;
run;
proc print data=Nandini.Sales (obs=20);run;

/*Descriptive Analysis Sales Vs Agesegment*/
proc means Data=Nandini.sales n nmiss var std cv clm mean sum min Q1 Q3 qrange max maxdec=2 ;
var Sales;
class Agesegment;
run;

/*Normality test Sales Vs Agesegment*/
proc univariate Data=Nandini.Sales normal plot;
var Sales;
Class Agesegment;
qqplot /normal (mu=est sigma=est);
run;
/*Ho- Sales in all group of Agesegment is normally distributed
H1- Sales in all group of Agesegment is not normally distributed*/
/*Since P value for all groups of AGesegment is <0.05. Hense we reject the null hypothesis and conclude that
Sales is not normally distributed in any agesegment .
However since the sample quantity in each group is large, by applying Central Limit Theoram we can consider 
the data is normally distributed */

/*Equality of variance Sales Vs Agesegement*/
proc glm data=Nandini.Sales;
class Agesegment;
model Sales = Agesegment;
means Agesegment / hovtest=levene(type=abs) welch;
run;
/*Ho= All groups of Equal variances
H1= All groups do not have equal variances

Since P value 0.0638 is > 0.05. we Fail to reject null hypothesis and conclude that variance of sales in all agesemnts is equal*/

/*Proving Sales is same in all agesegments */

/*H0= Means of Sales is equal across all agesegment
H1- Mean of Sales is not equal across all age segments*/

TITLE "Sales distribution across Age Segements";
PROC ANOVA DATA = Nandini.Sales;
 CLASS Agesegment;
 MODEL Sales = Agesegment;
 MEANS Agesegment/scheffe;
RUN;
QUIT;
title;

/*Since P value is 0.5216 >0.05 in anova procedure. we Fail to reject the Null Hypothesis and conclude that
means of sales is equal in all age groups.

/*Descriptive Analysis Sales Vs Status*/
proc means Data=Nandini.sales n nmiss var std cv clm mean sum min Q1 Q3 qrange max maxdec=2 ;
var Sales;
class Status;
run;

/*Normality test Sales Vs Status*/
proc univariate Data=Nandini.Sales normal plot;
var Sales;
Class Status;
qqplot /normal (mu=est sigma=est);
run;
/*Total sales ineach account status*/
proc sql;
select sum(sales)as Total_Sales,acct_status
from Nandini.Status_Tenure
group by Acct_Status;
quit;

/*Ho- Sales is normally distributed for both groups od status
H1- Sales is not normally distributed for both groups of status*/

/*Since P value for both status is <0.05. Hense we reject the null hypothesis and conclude that
Sales is not normally distributed in any status.
However since the sample quantity in each group is large, by applying Central Limit Theoram we can consider 
the data is normally distributed */

/*Equality of variance Sales Vs Status*/
proc glm data=Nandini.Sales;
class Status;
model Sales = Status;
means Status / hovtest=levene(type=abs) welch;
run;
/*Ho= All groups of Equal variances
H1= All groups do not have equal variances

Since P value 0.0505 is > 0.05. we Fail to reject null hypothesis and conclude that variance of sales in both status is equal*/

/*Proving Sales is same in both status*/
/*Ho- Mean of sales is same in both status
H1- Mean of sales is not same in both status*/
proc ttest Data=Nandini.Sales;
Var Sales;
Class status;
run;

/*The folded f value for equality of variance is 0.0475 <0.05, so we conclude that variances are not equeal for both status.
Going further we will refer Satterthwaite as the variances are unequal. P value in Satterthwaite is 0.3963>0.05.
hense
we fail to reject null hypotheis. and conclude mean of sales is same in both status*/

/*Descriptive Analysis Sales Vs Goodcredit*/
proc means Data=Nandini.sales n nmiss var std cv clm mean sum min Q1 Q3 qrange max maxdec=2 ;
var Sales;
class Goodcredit;
run;

/*Normality Test Sales Vs Agesegment*/
proc univariate Data=Nandini.Sales normal plot;
var Sales;
Class Goodcredit;
qqplot /normal (mu=est sigma=est);
run;
/*Total Sales classified between Good credit categories*/
proc sql;
select sum(sales )as Total_Sales_credit,Goodcredit
from Nandini.Sales
group by goodcredit;
quit;

/*Ho- Sales is normally distributed in both groups of Good credit
H1- Sales is not normally distributed both groups of Good credit */

/*Since P value for all groups of AGesegment is <0.05. Hense we reject the null hypothesis and conclude that
Sales is not normally distributed in both categories of Goodcredit .
However since the sample quantity in each group is large, by applying Central Limit Theoram we can consider 
the data is normally distributed */

/*Equality of variance*/
proc glm data=Nandini.Sales;
class Goodcredit;
model Sales = Goodcredit;
means Goodcredit / hovtest=levene(type=abs) welch;
run;

/*Ho= All groups of Equal variances
H1= All groups do not have equal variances

Since P value 0.6795 is > 0.05. we Fail to reject null hypothesis and conclude that variance of sales in 
both categories of Goodcredit is equal*/

/*Proving Sales is same in both status*/
/*Ho- Mean of sales is same in both categories of Goodcredit
H1- Mean of sales is not same in both categories of Goodcredit */
proc ttest Data=Nandini.Sales;
Var Sales;
Class Goodcredit;
run;

/*The folded f value for equality of variance is 0.2878 >0.05, so we conclude that variances are equeal for both categories of 
Goodcredit.
Going further we will refer Pooled test as the variances are equal. P value in Pooled Test 0.7788 is >0.05.
hense
we fail to reject null hypotheis. and conclude mean of sales is same in both categories of Goodcredit*/

/*Finally we can say that the Sales amount do not differ among different account statuses, GoodCredit, and
customer age segments */

/*COrrealtion between Sales - AGe and Sales -Tenuredays to find Sales depends upon Age of customers or number of days they 
availed telecom service*/

proc corr Data=Nandini.Status_Tenure;
var Tenuredays;
with Sales;
run;
proc reg data=Nandini.Status_Tenure;
model Sales= Tenuredays;
run;

proc corr Data=Nandini.Sales;
var Age;
with Sales;
run;
proc reg data=Nandini.Sales;
model Sales= Age ;
run;


proc surveyselect data=Nandini.Status_Tenure out=Nandini.Salecorr method=srs n=100;
run;
proc print data=Nandini.Salecorr;run;

proc corr Data=Nandini.Salecorr;
var Tenuredays;
with Sales;
run;
proc reg data=Nandini.Salecorr;
model Sales= Tenuredays;
run;

proc corr Data=Nandini.Salecorr;
var Age;
with Sales;
run;
proc reg data=Nandini.Salecorr;
model Sales= Age ;
run;

proc sql;
select sales,tenuredays
from Nandini.Status_Tenure
where Sales>900 and tenuredays<10;
quit;

proc sql;
select sales,Age
from Nandini.Status_Tenure
where Sales>900 and Age<5 and age ne .;
quit;

proc sql;
select sales,tenuredays
from Nandini.Status_Tenure
where Sales<100 and tenuredays>300;
quit;

proc corr Data=Nandini.Status_Tenure pearson spearman kendall 
plots(maxpoints=none) = matrix(histogram);
var Sales Age Tenuredays;
run;




