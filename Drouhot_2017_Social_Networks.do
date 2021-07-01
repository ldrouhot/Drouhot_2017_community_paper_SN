capture clear
capture log close
macro drop all
set more off 
set linesize 80
version 12

set scheme lean1

// Lucas Drouhot
// May 2016
// This program reproduces analyses from:
// Drouhot, Lucas G. 2017. "Reconsidering “community liberated”: How class and the national context shape personal support networks" Social Networks 48: 57-77.


// The data used is the 1986 edition of the International Social Survey, carried out in seven countries: 
// Australia, Austria, Great Britain, Hungary, Italy, the US and West Germany. The total number of respondents is 10,746.



capture clear
*use "" // Input path to ISSP data here

{ // GENERAL CLEANING AND LABELING


rename v3 country
replace country=7 if country==8
label define country_lbl  1 "Australia" 2 "West Germany" 3 "Great Britain" 4 "USA" 5 "Austria" 6 "Hungary" 7 "Italy" 
label value country country_lbl

rename v38 nmbfrnds
rename v40 friendneighbor
rename v39 friendwork
rename v43 distbstfrnd
rename v47 distbstscdfrnd
rename v49 helphouse
rename v51 helpillness
rename v53 helpborrow
rename v55 helpfamily
rename v57 helpdepression
rename v59 helpadvice
rename v61 howlonghere
rename v62 howlongherecat
rename v78 region
rename v80 age

replace age=21 if age==1
replace age=29.5 if age==2
replace age=39.5 if age==3
replace age=49.5 if age==4
replace age=59.5 if age==5
replace age=69.5 if age==6

// Note: the command above is just about Italy.


rename v81 sex
replace sex=0 if sex==2
label define gender 0 "Female" 1 "Male"
label values sex gender


rename v82 urban
rename v90 contfamincome
rename v91 discfamincome
rename v92 contrespincome
rename v93 discrespincome
rename v85 eduyrs
rename v83 marital

label define marital_status  1 "Married" 2 "Widowed (default is married)" 3 "Divorced" 4 "Separated" 5 "Never married"
label values marital marital_status


rename v96 religion
rename v97 church
gen church_attendance=.
replace church_attendance=1 if church==6
replace church_attendance=2 if church==5
replace church_attendance=3 if church==4
replace church_attendance=4 if church==3
replace church_attendance=5 if church==2
replace church_attendance=6 if church==1

gen agesquared=age*age
label var agesquare "age squared"
gen educentered=eduyrs-10.78795
label var educentered "Centered term for education years"
gen edusquared=educentered*educentered
label var edusquared "squared term for education years"


/// Next step: missing on friends...who has friends and who does not? Predict for absence or presence of friends. Also predict presence or absence of parents. 1800 reprort 0 friends...

}



{ // PREPARING THE URBAN / RURAL VARIABLE
/// Recoding the urban / rural variable to make it comparable across countries. Hungary has three category and constitutes in this regard the smallest common denominator. 
/// This variable is not available for the 1,416 UK respondents. Bummer. 

// Here is how I recode all countries in three categories based on the Hungarian coding: Central City / Smaller City / Rural. Different countries have different population intervals so these
// three discrete categories will not be exactly homoegenous across countries.

// Australia: 100k - Max = Large city, 1k-100k = smaller city, under 1k = rural, 99 are coded as missing or rural so I am going to assume they are rural
// West Germany: 100k - max = Large city, 5k-100k - smaller city, under 5k = rural
// USA: 250k - Max = large city, 10k-250k = smaller city, under 10k=rural
// Austria:50k - Max = Large city, 5k-50K = smaller city, under 5k=rural
// Italy:100k-max= LArge city, 5k-100k, smaller city, under 5k=rural
 
gen location=.
label var location "Urban or small town or rural"

// 1=Urban 2=Small town 3=Rural (NOTE: The brackets for the "or" condition are very important, otherwise it changes everything).

// Australia
replace location=1 if country==1 & (urban==1 | urban==2)
replace location=2 if country==1 & (urban==3 | urban==4)
replace location=3 if country==1 & (urban==5 | urban==6) 

// Germany
replace location=1 if country==2 & (urban==1 | urban==2 | urban==3 | urban==4)
replace location=2 if country==2 & (urban==5 | urban==6 | urban==7 | urban==8)
replace location=3 if country==2 & (urban==9 | urban==10)

// USA
replace location=1 if country==4 & (urban==1 | urban==2 | urban==3 | urban==4 | urban==5)
replace location=2 if country==4 & (urban==6 | urban==7 | urban==8)
replace location=3 if country==4 & (urban==9 | urban==10) 

// Note December 2015: I am going to recode the US rural as being less than 2,500. I recoded location==2 for US if urban == 8 (it was location==3 before).

// Austria
replace location=1 if country==5 & (urban==1 | urban==2) 
replace location=2 if country==5 & (urban==3 | urban==4 | urban==5)
replace location=3 if country==5 & (urban==6 | urban==7 | urban==8) 


// Italy
replace location=1 if country==7 & (urban==1 | urban==2)
replace location=2 if country==7 & (urban==3 | urban==4 | urban==5)
replace location=3 if country==7 & (urban==6)

// Hungary

replace location=urban if country==6

label define location_urban_or_rural  1 "Urban" 2 "Semirural (default is urban)" 3 "Rural"
label values location location_urban_or_rural


}


{ // PREPARING THE FAMILY INCOME VARIABLE
// I will use family level income because it is not missing as much - missing across some countries, of course.
// Here I use the middle point of each income bracket and convert everything in american dollars, using the average exchagne rate of the ten years preceding the survey.

// I here create a mirror variable that I might use later to do quantile placement and relative economic standing within the country. 

gen income_decile= discfamincome
replace income_decile=income_decile*(10/24) if country==1
replace income_decile=income_decile*(10/22) if country==2
replace income_decile=income_decile*(10/13) if country==3
replace income_decile=income_decile*(10/20) if country==4
replace income_decile=income_decile*(10/20) if country==5
replace income_decile=income_decile*(10/12) if country==6
replace income_decile=income_decile*(10/18) if country==7


// Australia

replace discfamincome=750 if country==1 & discfamincome==1
replace discfamincome=2000 if country==1 & discfamincome==2
replace discfamincome=3000 if country==1 & discfamincome==3
replace discfamincome=4000 if country==1 & discfamincome==4
replace discfamincome=5000 if country==1 & discfamincome==5
replace discfamincome=6000 if countr==1 & discfamincome==6
replace discfamincome=7000 if country==1 & discfamincome==7
replace discfamincome=8000 if country==1 & discfamincome==8
replace discfamincome=9000 if country==1 & discfamincome==9
replace discfamincome=10000 if country==1 &discfamincome==10
replace discfamincome=11000 if country==1 &discfamincome==11
replace discfamincome=12000 if country==1 &discfamincome==12
replace discfamincome=13000 if country==1 &discfamincome==13
replace discfamincome=14000 if country==1 &discfamincome==14
replace discfamincome=15000 if country==1 &discfamincome==15
replace discfamincome=18000 if country==1 &discfamincome==16
replace discfamincome=23000 if country==1 &discfamincome==17
replace discfamincome=28000 if country==1 &discfamincome==18
replace discfamincome=33000 if country==1 &discfamincome==19
replace discfamincome=40000 if country==1 &discfamincome==20
replace discfamincome=50000 if country==1 &discfamincome==21
replace discfamincome=60000 if country==1 &discfamincome==22
replace discfamincome=70000 if country==1 &discfamincome==23
replace discfamincome=80000 if country==1 &discfamincome==24

// Germany

replace discfamincome=200 if country==2 & discfamincome==1
replace discfamincome=500 if country==2 & discfamincome==2
replace discfamincome=700 if country==2 & discfamincome==3
replace discfamincome=900 if country==2 & discfamincome==4
replace discfamincome=1125 if country==2 & discfamincome==5
replace discfamincome=1375 if country==2 & discfamincome==6
replace discfamincome=1625 if country==2 & discfamincome==7
replace discfamincome=1875 if country==2 & discfamincome==8
replace discfamincome=2125 if country==2 & discfamincome==9
replace discfamincome=2375 if country==2 & discfamincome==10
replace discfamincome=2625 if country==2 & discfamincome==11
replace discfamincome=2875 if country==2 & discfamincome==12
replace discfamincome=3250 if country==2 & discfamincome==13
replace discfamincome=3750 if country==2 & discfamincome==14
replace discfamincome=4250 if country==2 & discfamincome==15
replace discfamincome=4750 if country==2 & discfamincome==16
replace discfamincome=5250 if country==2 & discfamincome==17
replace discfamincome=5750 if country==2 & discfamincome==18
replace discfamincome=7000 if country==2 & discfamincome==19
replace discfamincome=9000 if country==2 & discfamincome==20
replace discfamincome=12500 if country==2 & discfamincome==21
replace discfamincome=17500 if country==2 & discfamincome==22

* German survey reports monthly income so we need to multiply it by twelve.
replace discfamincome=discfamincome*12 if country==2

// Great Britain

replace discfamincome=1000 if country==3 & discfamincome==1
replace discfamincome=2500 if country==3 & discfamincome==2
replace discfamincome=3500 if country==3 & discfamincome==3
replace discfamincome=4500 if country==3 & discfamincome==4
replace discfamincome=5500 if country==3 & discfamincome==5
replace discfamincome=6500 if country==3 & discfamincome==6
replace discfamincome=7500 if country==3 & discfamincome==7
replace discfamincome=9000 if country==3 & discfamincome==8
replace discfamincome=11000 if country==3 & discfamincome==9
replace discfamincome=13500 if country==3 & discfamincome==10
replace discfamincome=16500 if country==3 & discfamincome==11
replace discfamincome=19000 if country==3 & discfamincome==12
replace discfamincome=21000 if country==3 & discfamincome==13


// USA


replace discfamincome=500 if country==4 & discfamincome==1
replace discfamincome=2000 if country==4 & discfamincome==2
replace discfamincome=3000 if country==4 & discfamincome==3
replace discfamincome=4500 if country==4 & discfamincome==4
replace discfamincome=5500 if country==4 & discfamincome==5
replace discfamincome=6500 if country==4 & discfamincome==6
replace discfamincome=7500 if country==4 & discfamincome==7
replace discfamincome=9000 if country==4 & discfamincome==8
replace discfamincome=11250 if country==4 & discfamincome==9
replace discfamincome=13750 if country==4 & discfamincome==10
replace discfamincome=16250 if country==4 & discfamincome==11
replace discfamincome=18750 if country==4 & discfamincome==12
replace discfamincome=21250 if country==4 & discfamincome==13
replace discfamincome=23750 if country==4 & discfamincome==14
replace discfamincome=27500 if country==4 & discfamincome==15
replace discfamincome=32500 if country==4 & discfamincome==16
replace discfamincome=37500 if country==4 & discfamincome==17
replace discfamincome=45000 if country==4 & discfamincome==18
replace discfamincome=55000 if country==4 & discfamincome==19
replace discfamincome=65000 if country==4 & discfamincome==20

// Austria

replace discfamincome=2000 if country==5 & discfamincome==1
replace discfamincome=5000 if country==5 & discfamincome==2
replace discfamincome=7000 if country==5 & discfamincome==3
replace discfamincome=9000 if country==5 & discfamincome==4
replace discfamincome=11000 if country==5 & discfamincome==5
replace discfamincome=13000 if country==5 & discfamincome==6
replace discfamincome=15000 if country==5 & discfamincome==7
replace discfamincome=17000 if country==5 & discfamincome==8
replace discfamincome=19000 if country==5 & discfamincome==9
replace discfamincome=21000 if country==5 & discfamincome==10
replace discfamincome=23000 if country==5 & discfamincome==11
replace discfamincome=25000 if country==5 & discfamincome==12
replace discfamincome=27000 if country==5 & discfamincome==13
replace discfamincome=29000 if country==5 & discfamincome==14
replace discfamincome=31000 if country==5 & discfamincome==15
replace discfamincome=33000 if country==5 & discfamincome==16
replace discfamincome=35000 if country==5 & discfamincome==17
replace discfamincome=37000 if country==5 & discfamincome==18
replace discfamincome=39000 if country==5 & discfamincome==19
replace discfamincome=41000 if country==5 & discfamincome==20

* Austrian survey reports monthly income so we need to multiply it by twelve.
replace discfamincome=discfamincome*12 if country==5

// Hungary


replace discfamincome=3000 if country==6 & discfamincome==1
replace discfamincome=6500 if country==6 & discfamincome==2
replace discfamincome=8750 if country==6 & discfamincome==3
replace discfamincome=11250 if country==6 & discfamincome==4
replace discfamincome=13750 if country==6 & discfamincome==5
replace discfamincome=16250 if country==6 & discfamincome==6
replace discfamincome=18750 if country==6 & discfamincome==7
replace discfamincome=22500 if country==6 & discfamincome==8
replace discfamincome=27500 if country==6 & discfamincome==9
replace discfamincome=35000 if country==6 & discfamincome==10
replace discfamincome=45000 if country==6 & discfamincome==11
replace discfamincome=75000 if country==6 & discfamincome==12

// Italy

replace discfamincome=150000 if country==7 & discfamincome==1
replace discfamincome=450000 if country==7 & discfamincome==2
replace discfamincome=750000 if country==7 & discfamincome==3
replace discfamincome=1050000 if country==7 & discfamincome==4
replace discfamincome=1350000 if country==7 & discfamincome==5
replace discfamincome=1650000 if country==7 & discfamincome==6
replace discfamincome=1950000 if country==7 & discfamincome==7
replace discfamincome=2250000 if country==7 & discfamincome==8
replace discfamincome=2550000 if country==7 & discfamincome==9
replace discfamincome=2850000 if country==7 & discfamincome==10
replace discfamincome=3150000 if country==7 & discfamincome==11
replace discfamincome=3450000 if country==7 & discfamincome==12
replace discfamincome=3750000 if country==7 & discfamincome==13
replace discfamincome=4050000 if country==7 & discfamincome==14
replace discfamincome=4350000 if country==7 & discfamincome==15
replace discfamincome=4650000 if country==7 & discfamincome==16
replace discfamincome=4950000 if country==7 & discfamincome==17
replace discfamincome=5250000 if country==7 & discfamincome==18

// Conversion of currencies to $US using the average exchange rate for each currency in the 10 years preceding the survey in each country - THIS IS THE MOETHOD FOR DRAFT 2 WHICH IAM NOT DOING NOW BECAUSE
// I AM USING THE PENN TABLES FOR BOTH EXCHANGE RATES AND PPP CONVERSION.  The command was therefore different in the earlier version of my do file.
// The data used for converting income in USD using international prices was done using Penn Tables for the 20 year period preceding the survey, that is, the 1965-1985 period. 

// Tranforming in USD using average exchange rates for the 1965-1985 period:

replace discfamincome=discfamincome/0.911809524 if country==1
replace discfamincome=discfamincome/2.930142857 if country==2
replace discfamincome=discfamincome/20.32 if country==5
replace discfamincome=discfamincome/44.69375 if country==6
replace discfamincome=discfamincome/893.5761905 if country==7

// Transforming in USD taking account the variation in local prices for the 1965-1985 period. The PPP multiplying factor can be seen in my excel spread sheet called "Transformation income".


replace discfamincome=discfamincome*1.041304762 if country==1
replace discfamincome=discfamincome*0.966728571 if country==2
replace discfamincome=discfamincome*1.09712381 if country==5
replace discfamincome=discfamincome*1.55421875 if country==6
replace discfamincome=discfamincome*1.209547619 if country==7


// Now putting everything back in the US bracket system of the US survey 

gen familyincome=.
replace familyincome=500 if discfamincome<=999.99 
replace familyincome=2000 if discfamincome>1000 & discfamincome<2999.99
replace familyincome=3500 if discfamincome>3000 & discfamincome<3999.99
replace familyincome=4500 if discfamincome>4000 & discfamincome<4999.99
replace familyincome=5500 if discfamincome>5000 & discfamincome<5999.99
replace familyincome=6500 if discfamincome>6000 & discfamincome<6999.99
replace familyincome=7500 if discfamincome>7000 & discfamincome<7999.99
replace familyincome=9000 if discfamincome>8000 & discfamincome<9999.99
replace familyincome=11250 if discfamincome>10000 & discfamincome<12499.99
replace familyincome=13750 if discfamincome>12500 & discfamincome<14999.99
replace familyincome=16250 if discfamincome>15000 & discfamincome<17499.99
replace familyincome=18750 if discfamincome>17500 & discfamincome<19999.99
replace familyincome=21250 if discfamincome>20000 & discfamincome<22499.99
replace familyincome=23750 if discfamincome>22500 & discfamincome<24999.99
replace familyincome=27500 if discfamincome>25000 & discfamincome<29999.99
replace familyincome=32500 if discfamincome>30000 & discfamincome<34999.99
replace familyincome=37500 if discfamincome>35000 & discfamincome<39999.99
replace familyincome=45000 if discfamincome>40000 & discfamincome<49999.99
replace familyincome=55000 if discfamincome>50000 & discfamincome<59999.99
replace familyincome=65000 if discfamincome>=60000 & discfamincome!=.

gen Kfamilyincome=familyincome/1000

label var familyincome "categorical family income in dollar"
label var Kfamilyincome "Family income in k$"

gen Kfamilyincomesquared=Kfamilyincome*Kfamilyincome
label var Kfamilyincomesquared "Squared term for income in K$"

gen UK_income=.
replace UK_income=familyincome/1000 if country==3

// Note that family income is missing 891 respondents. 
// Here I am using the Penn World Tables to transform income in PPP equivalent 1986 USD. 

}



{ // PREPARING  THE CATEGORICAL VARIABLE FOR EDUCATION
 // The values below are for when the respondents are still at school, at college, other answer and NA. I code them all as missing. 
 //Additionally, I trim the extreme values (below 3, above 20), for which number of respondents is dramatically lower.
replace eduyrs=. if eduyrs==95 
replace eduyrs=. if eduyrs==96 
replace eduyrs=. if eduyrs==97 
replace eduyrs=. if eduyrs==99 
replace eduyrs=. if eduyrs<3 
replace eduyrs=. if eduyrs>20



// For some countries, years of education is limited to an 8-13 range (Austria, the UK). For my analyses, I choose to use the categorical variable for education.
// But this rquires some cleaning and recoding because categories are country-specific. I am dropping UK here.

gen educat=.
label var educat "Education level"
replace educat=1 if country==1 & (v86==1 | v86==2 | v86==3) 
replace educat=2 if country==1 & v86==4
replace educat=3 if country==1 & v86==5
replace educat=4 if country==1 & (eduyrs>12 & eduyrs<15)
replace educat=5 if country==1 & eduyrs>=15

replace educat=1 if country==2 & v86==1 
replace educat=2 if country==2 & v86==2
replace educat=3 if country==2 & (v86==3 | v86==4 | v86==7)
replace educat=4 if country==2 & v86==8  | v86==5 | v86==6 | (v86==7 & eduyrs>=12)
replace educat=5 if country==2 & v86==9

replace educat=2 if country==3 & eduyrs==10
replace educat=3 if country==3 & (eduyrs==11 | eduyrs==12)
replace educat=4 if country==3 & eduyrs==13
replace educat=5 if country==3 & eduyrs==14

replace educat=1 if country==4 & v86==1
replace educat=2 if country==4 & v86==2
replace educat=3 if country==4 & v86==3
replace educat=4 if country==4 & v86==4
replace educat=5 if country==4 & v86==5
replace educat=5 if country==4 & v86==6

replace educat=2 if country==5 & v86==3
replace educat=3 if country==5 & (v86==4 | v86==5)
replace educat=4 if country==5 & (v86==6 | v86==7)
replace educat=5 if country==5 & v86==8

replace educat=1 if country==6 & (v86==1 | v86==2 | v86==3)
replace educat=2 if country==6 & v86==4
replace educat=3 if country==6 & v86==5
replace educat=4 if country==6 & v86==5 & eduyrs>13
replace educat=5 if country==6 & v86==7

replace educat=1 if country==7 & (v86==1 | v86==2 | v86==3)
replace educat=2 if country==7 & (v86==4 | v86==5 | v86==6)
replace educat=3 if country==7 & v86==7
replace educat=4 if country==7 & v86==8
replace educat=5 if country==7 & v86==9

// Note: the process of building a comparable variable for eduation categories involve some background research and potentially arbitrary decisions.
// I chose to consider completing high school in Italy equivalent to completing high school in the US, but it might be more like technical college. 

}


{ // PREPARING THE DISTANCE TO SUPPORT VARIABLES
//

rename v6 distmum
rename v10 distdad
rename v14 distsister
rename v18 distbro
rename v22 distdaught
rename v26 distson
rename v36 distother


// AVERAGE DISTANCE TO CLOSE KIN

capture drop dad mum bro sis daught son other nmbrelatives
gen dad=0
replace dad=1 if distdad!=.
gen mum=0
replace mum=1 if distmum!=.
gen bro=0
replace bro=1 if distbro!=.
gen sis=0
replace sis=1 if distsister!=.
gen daught=0
replace daught=1 if distdaught!=.
gen son=0
replace son=1 if distson!=.
gen other=0
replace other=1 if distother!=.
egen nmbrelatives=rowtotal (dad mum sis bro daught son other)

// This was for the denominator of our divison to get the average distance to named relatives. Now for the total distance from named relatives:

egen totaldistrelatives=rowtotal(distdad distmum distbro distsister distdaught distson distother)
gen meandistrelatives = (totaldistrelatives/nmbrelatives)
sum meandistrelatives
label var meandistrelatives "average distance to close kin"

// DISTANCE TO BEST FRIEND IS STRAIGHTFORWARD

// The social support variables are not all relevant to measuring distance. Some are inherently about
// who is closer (help around the house, help when sick in bed); I do not consider these meaningful for my analysis.

// The more meaningful variables are: who to ask for a large sum of money / help in depression / advice

// DISTANCE FROM MATERIAL SUPPORT

capture drop distborrow
gen distborrow=.
replace distborrow=distdad if helpborrow==3
replace distborrow=distmum if helpborrow==2
replace distborrow=distdaught if helpborrow==4
replace distborrow=distson if helpborrow==5
replace distborrow=distbro if helpborrow==7
replace distborrow=distsister if helpborrow==6
replace distborrow=distother if helpborrow==8
replace distborrow=distbstfrnd if helpborrow==9
replace distborrow=1 if helpborrow==11
sum distborrow

rename v54 helpborrow2
gen distborrow2=.
replace distborrow2=distdad if helpborrow2==3
replace distborrow2=distmum if helpborrow2==2
replace distborrow2=distdaught if helpborrow2==4
replace distborrow2=distson if helpborrow2==5
replace distborrow2=distbro if helpborrow2==7
replace distborrow2=distsister if helpborrow2==6
replace distborrow2=distother if helpborrow2==8
replace distborrow2=distbstfrnd if helpborrow2==9
replace distborrow2=1 if helpborrow2==11


// Additionally, we can consider that someone who borrows from a neighbor
// has a very local tie, so I recode distborrow as 1 for those wo borrow from neighbors (done above with v53=11).

// DISTANCE FROM MENTAL SUPPORT

gen disthelp=.
replace disthelp=distdad if helpdepression==3
replace disthelp=distmum if helpdepression==2
replace disthelp=distdaught if helpdepression==4
replace disthelp=distson if helpdepression==5
replace disthelp=distbro if helpdepression==7
replace disthelp=distsister if helpdepression==6
replace disthelp=distother if helpdepression==8
replace disthelp=distbstfrnd if helpdepression==9
replace disthelp=1 if helpdepression==11

rename v58 helpdepression2
gen disthelp2=.
replace disthelp2=distdad if helpdepression2==3
replace disthelp2=distmum if helpdepression2==2
replace disthelp2=distdaught if helpdepression2==4
replace disthelp2=distson if helpdepression2==5
replace disthelp2=distbro if helpdepression2==7
replace disthelp2=distsister if helpdepression2==6
replace disthelp2=distother if helpdepression2==8
replace disthelp2=distbstfrnd if helpdepression2==9
replace disthelp2=1 if helpdepression2==11



// I add in house support (husband and wife) and code it as "local"

// replace disthelp=1 if helpdepression==1
sum disthelp

// DISTANCE FROM ADVICE

gen distadvice=.
replace distadvice=distmum if helpadvice==2
replace distadvice=distdad if helpadvice==3
replace distadvice=distdaught if helpadvice==4
replace distadvice=distson if helpadvice==5
replace distadvice=distsister if helpadvice==6
replace distadvice=distbro if helpadvice==7
replace distadvice=distother if helpadvice==8
replace distadvice=distbstfrnd if helpadvice==9
replace distadvice=1 if helpadvice==11


rename v60 helpadvice2
gen distadvice2=.
replace distadvice2=distmum if helpadvice2==2
replace distadvice2=distdad if helpadvice2==3
replace distadvice2=distdaught if helpadvice2==4
replace distadvice2=distson if helpadvice2==5
replace distadvice2=distsister if helpadvice2==6
replace distadvice2=distbro if helpadvice2==7
replace distadvice2=distother if helpadvice2==8
replace distadvice2=distbstfrnd if helpadvice2==9
replace distadvice2=1 if helpadvice2==11

// DISTANCE FROM FAMILY HELP

gen distfamhelp=.
replace distfamhelp=distmum if helpfamily==2
replace distfamhelp=distdad if helpfamily==3
replace distfamhelp=distdaught if helpfamily==4
replace distfamhelp=distson if helpfamily==5
replace distfamhelp=distsister if helpfamily==6
replace distfamhelp=distbro if helpfamily==7
replace distfamhelp=distother if helpfamily==8
replace distfamhelp=distbstfrnd if helpfamily==9
replace distfamhelp=1 if helpfamily==11

rename v56 helpfamily2
gen distfamhelp2=.
replace distfamhelp2=distmum if helpfamily2==2
replace distfamhelp2=distdad if helpfamily2==3
replace distfamhelp2=distdaught if helpfamily2==4
replace distfamhelp2=distson if helpfamily2==5
replace distfamhelp2=distsister if helpfamily2==6
replace distfamhelp2=distbro if helpfamily2==7
replace distfamhelp2=distother if helpfamily2==8
replace distfamhelp2=distbstfrnd if helpfamily2==9
replace distfamhelp2=1 if helpfamily2==11

// The command line below harmonizes linearizes distance variables in terms of hour (instead of 1-8 with various intervals in between).

local depvars "distbstfrnd distborrow distborrow2 disthelp disthelp2 distadvice distadvice2 distfamhelp distfamhelp2"

foreach dv in `depvars' { 
replace `dv'=0.25 if `dv'==1
replace `dv'=0.375 if `dv'==2
replace `dv'=0.75 if `dv'==3
replace `dv'=1.5 if `dv'==4
replace `dv'=2.5 if `dv'==5
replace `dv'=4 if `dv'==6
replace `dv'=8.5 if `dv'==7
replace `dv'=12 if `dv'==8
}
 
 
gen logdisthelp=ln(disthelp)
gen logdistadvice=ln(distadvice)
gen logdistborrow=ln(distborrow)
gen logdistfamhelp=ln(distfamhelp)

gen logdisthelp2=ln(disthelp2)
gen logdistadvice2=ln(distadvice2)
gen logdistborrow2=ln(distborrow2)
gen logdistfamhelp2=ln(distfamhelp2)

gen degree=nmbrelatives+nmbfrnds

{ /// Counting missing data on distance variables

count if helpborrow==2 & distmum==.
count if helpborrow==3 & distdad==.
count if helpborrow==4 & distdaught==.
count if helpborrow==5 & distson==.
count if helpborrow==6 & distsis==.
count if helpborrow==7 & distbro==.
count if helpborrow==8 & distother==.
count if helpborrow==9 & distbstfrnd==.

count if helpadvice==2 & distmum==.
count if helpadvice==3 & distdad==.
count if helpadvice==4 & distdaught==.
count if helpadvice==5 & distson==.
count if helpadvice==6 & distsis==.
count if helpadvice==7 & distbro==.
count if helpadvice==8 & distother==.
count if helpadvice==9 & distbstfrnd==.

count if helpdepression==2 & distmum==.
count if helpdepression==3 & distdad==.
count if helpdepression==4 & distdaught==.
count if helpdepression==5 & distson==.
count if helpdepression==6 & distsis==.
count if helpdepression==7 & distbro==.
count if helpdepression==8 & distother==.
count if helpdepression==9 & distbstfrnd==.

count if helpfamily==2 & distmum==.
count if helpfamily==3 & distdad==.
count if helpfamily==4 & distdaught==.
count if helpfamily==5 & distson==.
count if helpfamily==6 & distsis==.
count if helpfamily==7 & distbro==.
count if helpfamily==8 & distother==.
count if helpfamily==9 & distbstfrnd==.

count if helpborrow2==2 & distmum==.
count if helpborrow2==3 & distdad==.
count if helpborrow2==4 & distdaught==.
count if helpborrow2==5 & distson==.
count if helpborrow2==6 & distsis==.
count if helpborrow2==7 & distbro==.
count if helpborrow2==8 & distother==.
count if helpborrow2==9 & distbstfrnd==.

count if helpadvice2==2 & distmum==.
count if helpadvice2==3 & distdad==.
count if helpadvice2==4 & distdaught==.
count if helpadvice2==5 & distson==.
count if helpadvice2==6 & distsis==.
count if helpadvice2==7 & distbro==.
count if helpadvice2==8 & distother==.
count if helpadvice2==9 & distbstfrnd==.

count if helpdepression2==2 & distmum==.
count if helpdepression2==3 & distdad==.
count if helpdepression2==4 & distdaught==.
count if helpdepression2==5 & distson==.
count if helpdepression2==6 & distsis==.
count if helpdepression2==7 & distbro==.
count if helpdepression2==8 & distother==.
count if helpdepression2==9 & distbstfrnd==.

count if helpfamily2==2 & distmum==.
count if helpfamily2==3 & distdad==.
count if helpfamily2==4 & distdaught==.
count if helpfamily2==5 & distson==.
count if helpfamily2==6 & distsis==.
count if helpfamily2==7 & distbro==.
count if helpfamily2==8 & distother==.
count if helpfamily2==9 & distbstfrnd==.



}

// Same thing for husband/wife as above for mental support. If I decide to nottake them into account, I need to acknowledge the great importance of partners
// in providing social support. 
// replace distadvice=1 if helpadvice==1 

}


{ // PREPARING THE SOCIAL INV. W/ NEIGHBORS VARIABLE
// PROPORTION OF NEIGHBORS AMONG FRIENDS

// There are two key variables here: the absolute number of neighbors among the elicited number of friends - directly elicited in v40 - 
// as well as the porportion of neighbors - that is, v40 relative to v38.

replace friendneighbor=. if friendneighbor >=95

// This "95" friends that are also neighbors ought to be a mistake in coding.

// What seems to be the case here is that 2,002 respondents consider neighbor to be friends even if they do not count them
// as "friends" when asked their number of friends...IE these 2,002 people have more 'neighbors that are friends" that total number of friends elicited just earlier.
// it's more that they are friendly to their neighbors - but the questionnaire explicityly said "how many of these friends are your close neighbors"
// This being said, I should keep both the absolute of neighbors that are friends and the proportion of neighbors among friends. 

gen propfrndneighbor=(friendneighbor/nmbfrnds)
// Note: the missing values generated are due to 2,000+ missing values on that question. 

// Before computing the command below, I have 2139 respondents with proportion > 1. I don't understand where this comes from...in the tab command they do not appear.
// I am especially worried because this might rtefactually increase the proportion of people who are entirely dependent on neighbors for friends...
// Update: got it. When propfrndneighbor is missing, it considers it >1. What an idiot...

replace propfrndneighbor=1 if propfrndneighbor>1 & propfrndneighbor!=.
sum propfrndneighbor

// Ok, that's the clean variable without the missing proportion (due to missing either on total number of friends or number of neighbor friends)
// being counted as one...I also thought it was a lot of people with % of friends being also neighbors. 

}





{ // PREPARING THE SPECIALIZATION VARIABLES

// Total number of unique alters in support systems 

// STRONG TIES
gen uniqueborrow=0
replace uniqueborrow=1 if helpborrow<13 & helpborrow!=0
gen uniquehelp=0
replace uniquehelp=1 if helpdepression<13 & helpdepression!=0 & helpdepression!=helpborrow
gen uniqueadvice=0 
replace uniqueadvice=1 if helpadvice<13 & helpadvice!=0 & helpadvice!=helpborrow & helpadvice!=helpdepression
gen uniquefamily=0
replace uniquefamily=1 if helpfamily<13 & helpfamily!=0 & helpfamily!=helpadvice & helpfamily!=helpdepression & helpfamily!=helpborrow

gen specialized_strong=uniqueadvice+uniquehelp+uniqueborrow+uniquefamily

// SMALL SERVICES (MAY OVERLAP WITH STRONG TIES) - NOTE MAY 2015: Here I am also adding the possiblity of having up to 4 unique providers ///
// of local help when combining with secondary persons asked (e.g. 50 & v52).

// Measure 1 primary VS secondary:

gen uniqueillness=.
replace uniqueillness=0 if helpillness!=.
replace uniqueillness=1 if helpillness<13 & helpillness!=0 & helpillness!=.
gen uniquehouse=.
replace uniquehouse=0 if helphouse!=.
replace uniquehouse=1 if helphouse<13 & helphouse!=0 & helphouse!=helpillness & helphouse!=.
gen uniqueillness2=.
replace uniqueillness2=0 if v52!=.
replace uniqueillness2=1 if v52<13 & v52!=. 
gen uniquehouse2=.
replace uniquehouse2=0 if v50!=.
replace uniquehouse2=1 if v50<13 & v50!=v52 & v50!=. 
gen uniqueillness3=0
replace uniqueillness3=1 if v50<13 & v50!=. & v50!=helpillness & v50!=helphouse
gen uniquehouse3=0
replace uniquehouse3=1 if v52<13 & v52!=. & v52!=helpillness & v52!=helphouse & v52!=v50

gen primary_local_help=uniqueillness+uniquehouse
gen secondary_local_help=uniqueillness2+uniquehouse2
gen total_local_help=uniqueillness+uniquehouse+uniqueillness3+uniquehouse3

// Measure 2 help for illness VS help around the house:

gen house_1=0
replace house_1=1 if helphouse<13 & helphouse!=0 & helphouse!=.
gen house_2=0
replace house_2=1 if v50<13 & v50!=. & v50!=helphouse

gen local_help_house= house_1+house_2

gen illness_1=0
replace illness_1=1 if helpillness<13 & helpillness!=0 & helpillness!=.
gen illness_2=0
replace illness_2=1 if v52<13 & v52!=. & v52!=helpillness

gen local_help_illness=illness_1+illness_2






// Here I am creating another variable for unique secondary support (which may not overlap with specialized_strong, unlike specialized_help). 

gen uniqueillness_2=0.
replace uniqueillness_2=1 if helpillness<13 & helpillness!=0 & helpillness!=helpborrow & helpillness!=helpdepression & helpillness!=helpadvice & helpillness!=helpfamily
gen uniquehouse_2=0
replace uniquehouse_2=1 if helphouse<13 & helphouse!=0 & helphouse!=helpillness & helphouse!=helpborrow & helphouse!=helpdepression & helphouse!=helpadvice & helphouse!=helpfamily

gen specialized_service=uniqueillness_2+uniquehouse_2

// This is the number of unique alters for the overall support system (strong ties, ie borrowing money, help in depression, advice, and help with family issues as well as smal services, help when ill and help around the house)

gen grand_specialization=specialized_strong+specialized_service

}






{ // PREPARING WEIGHTS FOR MISSING DATA
 
 // Whether or not people certain people have "no one"
 
gen no_help_depression=0
replace no_help_depression=1 if helpdepression==0 | helpdepression==.
 
gen no_help_borrow=0
replace no_help_borrow=1 if helpborrow==0 | helpborrow==.

gen no_help_advice=0
replace no_help_advice=1 if helpadvice==0 | helpadvice==.

gen no_help_family=0
replace no_help_family=1 if helpfamily==0 | helpfamily==.

gen no_help_depression2=0
replace no_help_depression2=1 if helpdepression2==. 
 
gen no_help_borrow2=0
replace no_help_borrow2=1 if helpborrow2==. 

gen no_help_advice2=0
replace no_help_advice2=1 if helpadvice2==. 

gen no_help_family2=0
replace no_help_family2=1 if helpfamily2==. 


foreach i in no_help_depression no_help_borrow no_help_advice no_help_family no_help_depression2 no_help_borrow2 no_help_advice2 no_help_family2  {
	logit `i' age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country, cluster(country) robust
	estimates store tab_`i'	
}

esttab tab_no_help_depression tab_no_help_borrow tab_no_help_advice tab_no_help_family tab_no_help_depression2 tab_no_help_borrow2 tab_no_help_advice2 tab_no_help_family2  ///
using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Missingness_because_no_alters.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 


//sum y x

//reg y x

//inthereg = e(sample) // e(sample) var 0/1 where 1 means that obs is part of sample used in the reg above.


 // Supplementary on relationship to institutions VS informal support 

 
gen depressioninstit=0
replace depressioninstit=1 if helpdepression==13 | helpdepression==14 | helpdepression==15
gen adviceinstit=0
replace adviceinstit=1 if helpadvice==13 | helpadvice==14 | helpadvice==15 | helpadvice==16
gen borrowinstit=0
replace borrowinstit=1 if helpborrow==13 | helpborrow==14 | helpborrow==15
gen helpfaminstit=0
replace helpfaminstit=1 if helpfamily==13 | helpfamily==14 | helpfamily==15

gen depressioninstit2=0
replace depressioninstit2=1 if helpdepression2==13 | helpdepression2==14 | helpdepression2==15
gen adviceinstit2=0
replace adviceinstit2=1 if helpadvice2==13 | helpadvice2==14 | helpadvice2==15 | helpadvice2==16
gen borrowinstit2=0
replace borrowinstit2=1 if helpborrow2==13 | helpborrow2==14 | helpborrow2==15
gen helpfaminstit2=0
replace helpfaminstit2=1 if helpfamily2==13 | helpfamily2==14 | helpfamily2==15


foreach i in borrowinstit depressioninstit adviceinstit helpfaminstit borrowinstit2 depressioninstit2 adviceinstit2 helpfaminstit2 {
	logit `i' age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country, cluster(country) robust
	estimates store tab_`i'
}
	
esttab tab_borrowinstit tab_depressioninstit tab_adviceinstit tab_helpfaminstit tab_borrowinstit2 tab_depressioninstit2 tab_adviceinstit2 tab_helpfaminstit2  ///
using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Missingness_by_institutions_both_alters.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

// Education level is unrelated to the likelihood to seek support from formal institutions for three major support. This varies strongly by country, age, and, to a lesser extent, income amd church attendance.

// The next step is to buid a model predicting both patterns of missingness, missing alters and institutions.
 // Maybe include those who reference their spouse here, too...I include spouse because it brings missingness in the main outcome variables. 

gen miss_disthelp=0
replace miss_disthelp=1 if helpdepression==. | helpdepression==0 | helpdepression==1 | helpdepression==13 | helpdepression==14 | helpdepression==15

gen miss_distadvice=0
replace miss_distadvice=1 if helpadvice==. | helpadvice==0 | helpadvice==1 | helpadvice==13 | helpadvice==14 | helpadvice==15 | helpadvice==16

gen miss_distborrow=0
replace miss_distborrow=1 if helpborrow==.| helpborrow==0 | helpborrow==1 | helpborrow==13 | helpborrow==14 | helpborrow==15

gen miss_distfamhelp=0
replace miss_distfamhelp=1 if helpfamily==. | helpfamily==0 | helpfamily==1 | helpfamily==13 | helpfamily==14 | helpfamily==15

gen miss_disthelp2=0
replace miss_disthelp2=1 if helpdepression2==. | helpdepression2==1 | helpdepression2==13 | helpdepression2==14 | helpdepression2==15

gen miss_distadvice2=0
replace miss_distadvice2=1 if helpadvice2==. | helpadvice2==1 | helpadvice2==13 | helpadvice2==14 | helpadvice2==15 | helpadvice2==16

gen miss_distborrow2=0
replace miss_distborrow2=1 if helpborrow2==. | helpborrow2==1| helpborrow2==13 | helpborrow2==14 | helpborrow2==15

gen miss_distfamhelp2=0
replace miss_distfamhelp2=1 if helpfamily2==. | helpfamily2==1| helpfamily2==13 | helpfamily2==14 | helpfamily2==15

// Adding missingness in having neighbor-friends and local help

gen miss_propfneighbor=0
replace miss_propfrndneighbor=1 if nmbfrnds==. | friendneighbor==.

gen miss_primary_local_help=0
replace miss_primary_local_help=1 if uniqueillness==. | uniquehouse==.

gen miss_secondary_local_help=0
replace miss_secondary_local_help=1 if v50==. | v52==.

capture drop pr_*
capture drop weight_*

foreach i in miss_disthelp miss_distadvice miss_distborrow miss_distfamhelp miss_disthelp2 miss_distadvice2 miss_distborrow2 miss_distfamhelp2 miss_propfrndneighbor miss_primary_local_help miss_secondary_local_help  {
	logit `i' age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country, cluster(country) robust
	estimates store tab_`i'
	
			
			gen weight_country_`i'=.
			foreach j in 1 2 4 5 6 7 {			
				capture sum country if e(sample)==1 
				local NN=r(N)
				capture sum country if country==`j' & e(sample)==1 
				local nn=r(N)
				capture replace weight_country_`i'= `NN'/(6*`nn') if country==`j'
			}

		
	predict pr_`i', pr
	sum pr_`i'
	gen weight_`i'=(1/(1-pr_`i')) * (1-r(mean))
	gen final_weight_`i'= weight_`i' * weight_country_`i'
	
}
	
	

esttab tab_miss_disthelp tab_miss_distadvice tab_miss_distborrow tab_miss_distfamhelp tab_miss_disthelp2 tab_miss_distadvice2 tab_miss_distborrow2 tab_miss_distfamhelp2  ///
using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Missingness_combining_missing_alters_&_institutions.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

// This is the weighting procedure by country. There are 9,330 individuals across our 6 countries but sample sizes differ. They would each be 1,555 each they were equal. 

capture drop weight_country
gen weight_country=.
forval i=1/7 {
	qui sum country if country==`i'
	replace weight_country=1/(r(N)) if country==`i'
	
}


// The final weights are thus given by: 

foreach i in miss_disthelp miss_distadvice miss_distborrow miss_distfamhelp miss_disthelp2 miss_distadvice2 miss_distborrow2 miss_distfamhelp2  {
	gen final_weight_`i'=weight_country*weight_`i'
}
	
// Problem right now: the weights for each type of missingness do not sum up to the sample size. 
	
	
}




////////////////////////// ANALYSES START HERE //////////////////////////

cd "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material


{ // FACTOR ANALYSIS

// I use the usual scaling method of dividing each variable by its standard deviation (Note: in fact I deleted the command for that and did not scale anything).

sum  distborrow distborrow2 disthelp disthelp2 distadvice distadvice2 distfamhelp distfamhelp2 propfrndneighbor primary_local_help 

bysort country: fact distborrow disthelp distadvice distfamhelp propfrndneighbor, ml
bysort country:	fact distborrow2 disthelp2 distadvice2 distfamhelp2, ml
bysort country:	alpha distborrow disthelp distadvice distfamhelp, item
bysort country:	alpha distborrow2 disthelp2 distadvice2 distfamhelp2, item


alpha  distborrow distborrow2 disthelp disthelp2 distadvice distadvice2 distfamhelp distfamhelp2 propfrndneighbor primary_local_help , item

//predict networklocalism, regression
//reg networklocalism age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
}
{ // WITHIN COUNTRY ANALYSIS OF DISTANCE TO SUPPORT

/////// HERE ARE SOME OBSERVATIONS THAT CAME UP WHEN RUNNING EXPLORATORY AND DIAGNOSTIC TESTS.
// - Make diagnostic tests for BLUE but write the codes for standard regression anyway. Also, take into account missingness the way Mauricio mentioned 
// (who has friend? Likelihood to rely on formal VS informal means to get money? etc). 
// - Within-country test for effect of location are needed. 
// - The effect of education on distance to help in depression is unclear. The ambiguity is that the coefficients for education varies...in the more promising model
//  (fixed effect w/o location) it is not significant, otherwise barely significant in the unexpected direction.
// - The outcome variables here is not normally distributed. Additionally, the Cook-Weisberg test reveals strong heteroskedasticity.
// - When removing education, we observe a strong difference between urban and rural across the sample. 
// - The difference in the effects of demographic controls on proportion of neighbor friends between the no fixed / fixed effect models is striking. What is going on?
// - The absence of F statistics in the regression outputs need to be fixed. 
// - This seems to come from the clustering of standard errors by country. I note that clustering has a strong effect of the significance of the country-level fixed effect. 

// WITHIN COUNTRY EXPLORATORY ANALYSIS ON 4 OUTCOME VARIABLES:

local depvars "distborrow disthelp distadvice propfrndneighbor"


foreach dv in `depvars' { 

foreach i in 1 2 4 5 6 7 {
	reg  `dv' age agesquared i.sex i.marital i.location church_attendance c.familyincome##c.familyincome v86 if country==`i', beta robust
	estimates store tab_`dv'_`i'
}

qui reg `dv' age agesquared i.sex marital church_attendance discfamincome educat if country==3, beta robust
estimates store tab_UK_`dv'

esttab tab_`dv'_* tab_UK_`dv' using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Within_country_`dv'_ISS_data.rtf", replace se r2 label mtitles starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)
}

local depvars2 "distborrow2 disthelp2 distadvice2"

foreach dv in `depvars2' { 

foreach i in 1 2 4 5 6 7 {
	reg  `dv' age agesquared i.sex i.marital i.location church_attendance c.familyincome##c.familyincome v86 if country==`i', beta robust
	estimates store tab_`dv'_`i'
}

qui reg `dv' age agesquared i.sex marital church_attendance discfamincome educat if country==3, beta robust
estimates store tab_UK_`dv'
}
esttab tab_`dv'_* tab_UK_`dv' using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Within_country_`dv'_ISS_data_second_alter.rtf", replace se r2 label mtitles starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)



// Note here: November 2015. I just changed the directory for outputs of graphs because I am changing a few measures and codes so that the coefficeitns will probably be different. In particular, I changed the urban/rural coding for the US.

// For distance to close kin: education is consistently significant (except in Austria). Same direction but not significant in Hungary. 
//							  church attendance is invertly related to distance to kin. Family proximity and church attendance go together. However, the effect is reversed in England.
//							  urbanism has an effect in some country: urban people are farther from close kin in Germany, Austria, Hungary, and Italy. 
//							  marital status has a strong positive effect on distance in West Germany. 
//							  Age has a curvilinear effect in 4 countries: Aus, WG, USA and GB. Logically, age is positively related to distance while age squared is not. 
//							  Sex is by and alrge unrelated.

// For distance to best friend: 
//							  Education is consistently related to distance to bst friend, too.
//							  Church attendance has a similarly inconsistent effect (less religious people are farther from their best friend in Italy, WG and the US but closer in England))
//							  Effect of location is also context bound: urban/rural difference is at play in WG, Austria, strongly in Hungary (as strongly as for kin), and barely insignificant in Italy.
//							  Age, sex and marital status are not related to distance to best friend.

// For distance to financial support:
//							  Despite small size of each country-level subsample, education is strongly significant.
//							  Urbanism is significant in Austria, Italy and Hungary. 

// For distance to mental support:
//							  Education is significant in 4 countries, not significant in Australia and Austria and otherwise towards significance in Hungary. 
//							  Urban VS rural location is significant in Austria and Hungary in the expected direction. 
//							  Age has a marked curvilinear effect in Italy and WG. 

// For distance to advisor:   Education has a strong effect as predicted in WG, the US and England. By and large the only strong predictor. 




// NOTE NOVEMBER 2015: I DECIDED SO FAR NOT TO INCLUDE ANY INTERACTION ON URBANISM. I EXPLORE HOW DISTANCE VARIABLES MIGHT VARY BY LOCATIONAL STATUS ACROSS COUNTRIES THROUGH A CATEGORICAL DESCRIPTIVE PLOT:

}

{ // POOLED COUNTRY ANALYSIS WITH FIXED EFFECT OF DISTANCE TO SUPPORT ACROSS 1ST DEGREE AND 2ND DEGREE SUPPORT

local depvars "distborrow disthelp distadvice distfamhelp"

foreach dv in `depvars' { 

xi: reg log`dv' age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=final_weight_miss_`dv'], cluster(country) robust
estimates store tab_log`dv'
}

esttab tab_logdistborrow tab_logdisthelp tab_logdistadvice tab_logdistfamhelp using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data.rtf", ///
 replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 


local depvars "distborrow2 disthelp2 distadvice2 distfamhelp2"

foreach dv in `depvars' { 

xi: reg  log`dv' age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=final_weight_miss_`dv'], cluster(country) robust
estimates store tab_log`dv'
}

esttab tab_logdistborrow2 tab_logdisthelp2 tab_logdistadvice2 tab_logdistfamhelp2 using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_second_alter.rtf", ///
replace b(3) se (3) r2(3) coeflabels(1b.sex "Male") label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 
}


{ // MARGINAL GRAPHS FOR DISTANCE TO PRIMARY AND SECONDARY SUPPORT PROVIDERS:

//// Marginal graphs for the effect of education of primary social support providers:

local depvars "logdistborrow logdisthelp logdistadvice logdistfamhelp propfrndneighbor"

reg logdistborrow age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country) expression(exp(predict(xb)))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to material support (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_logdistborrow, replace

reg logdisthelp age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)  expression(exp(predict(xb)))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to mental support (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_logdisthelp, replace

reg logdistadvice age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)  expression(exp(predict(xb)))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to advisor (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_logdistadvice, replace

reg logdistfamhelp age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)  expression(exp(predict(xb)))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to support for marital issues (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_logdistfamhelp, replace


grc1leg educ_logdistborrow.gph educ_logdisthelp.gph educ_logdistadvice.gph educ_logdistfamhelp.gph, altshrink  title("")

//////////////////******************

// Same interactions for distance to secondary support providers:

reg distborrow2 age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to secondary material support (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_distborrow2, replace

reg disthelp2 age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to secondary mental support (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_disthelp2, replace

reg distadvice2 age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to secondary advisor (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_distadvice2, replace

reg distfamhelp2 age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(small)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("Distance to secondary support for marital issues (hours)") title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) ///
msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) ///
 plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save educ_distfamhelp2, replace


grc1leg educ_distborrow2.gph educ_disthelp2.gph educ_distadvice2.gph educ_distfamhelp2.gph, altshrink  title("")





}




{ // AS PER REVIEWER 2's REQUEST: ANALYSIS OF THE UK DATA

local depvars "logdistborrow logdisthelp logdistadvice logdistfamhelp propfrndneighbor"

foreach dv in `depvars' { 

xi: reg  `dv' age agesquared i.sex i.marital church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat if country==3, robust
estimates store tab_`dv'
margins,  at(Kfamilyincome=(0(1)25)) atmeans
marginsplot
graph save income_`dv', replace
margins,  at(educat=(0(1)5)) atmeans
marginsplot
graph save educat_`dv', replace

}

esttab tab_logdistborrow tab_logdisthelp tab_logdistadvice tab_logdistfamhelp tab_propfrndneighbor using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_UK_only.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 


local depvars "logdistborrow2 logdisthelp2 logdistadvice2 logdistfamhelp2"

foreach dv in `depvars' { 

reg  `dv' age agesquared i.sex i.marital church_attendance degree c.UK_income#c.UK_income c.educat if country==3, robust
estimates store tab_`dv'
}

local depvars "distborrow2 disthelp2 distadvice2 distfamhelp2"

foreach dv in `depvars' { 

reg  `dv' age agesquared i.sex i.marital church_attendance degree c.UK_income#c.UK_income c.educat if country==3, robust
estimates store tab_`dv'

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("% neighbors among friends", size(medsmall)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea)
graph save educ_UK_`dv', replace
}

esttab tab_logdistborrow2 tab_logdisthelp2 tab_logdistadvice2 tab_logdistfamhelp2 using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_UK_only_secondary.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 
graph combine educ_UK_distborrow2.gph educ_UK_disthelp2.gph educ_UK_distadvice2.gph educ_UK_distfamhelp2.gph

}

{ // PROPORTION OF NEIGHBORS AMONG FRIENDS AND NUMBER OF LOCAL HELP PROVIDERS

// general models

eststo clear
reg propfrndneighbor age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_propfrndneighbor

ologit primary_local_help age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_primary_local_help

ologit secondary_local_help age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_secondary_local_help

esttab tab_propfrndneighbor tab_primary_local_help tab_secondary_local_help using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Neighboring_&_local_help.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

// Separate models for the UK:

eststo clear
reg propfrndneighbor age agesquared i.sex i.marital church_attendance degree c.UK_income##c.UK_income v86 if country==3, robust
estimates store tab_propfrndneighbor

ologit primary_local_help age agesquared i.sex i.marital church_attendance degree c.UK_income##c.UK_income v86 if country==3, robust
estimates store tab_primary_local_help

ologit secondary_local_help age agesquared i.sex i.marital church_attendance degree c.UK_income##c.UK_income v86 if country==3, robust
estimates store tab_secondary_local_help

esttab tab_propfrndneighbor tab_primary_local_help tab_secondary_local_help using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Neighboring_&_local_help_UK.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

// General table for the UK:

eststo clear

local depvars "logdistborrow logdisthelp logdistadvice logdistfamhelp propfrndneighbor logdistborrow2 logdisthelp2 logdistadvice2 logdistfamhelp2"

foreach dv in `depvars' { 

reg  `dv' age agesquared i.sex i.marital church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat if country==3, robust
estimates store tab_UK_`dv'
}

reg propfrndneighbor age agesquared i.sex i.marital church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat if country==3, robust
estimates store tab_UKpropfrndneighbor

ologit primary_local_help age agesquared i.sex i.marital church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat if country==3, robust
estimates store tab_UK_primary_local_help

ologit secondary_local_help age agesquared i.sex i.marital church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat if country==3, robust
estimates store tab_UK_secondary_local_help

esttab tab_UK_logdistborrow tab_UK_logdisthelp tab_UK_logdistadvice tab_UK_logdistfamhelp tab_UK_logdistborrow2 tab_UK_logdisthelp2 tab_UK_logdistadvice2 tab_UK_logdistfamhelp2 tab_UK_propfrndneighbor tab_UK_primary_local_help tab_UK_secondary_local_help ///
using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_UK_only_secondary.rtf", ///
replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

// Note: the results when using the originally coded variables VS the cross-country standardized variables do not change results  for the UK.

// Models w/ interactions for marginal graphs:

reg propfrndneighbor age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust

margins,  at(educat=(0(1)5)) atmeans over(country) 

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(medsmall)) ytitle("% neighbors among friends", size(medsmall)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus))
graph save educ_propfrndneighbor, replace

// MEASURE 1 FOR LOCAL HELP (PRIMARY VS SECONDARY)

ologit primary_local_help age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust

margins,  at(educat=(0(1)5)) atmeans over(country) predict(outcome(2))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(vsmall)) ytitle("Probability for 2 different primary providers of local support", size(small)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save primary_local_help, replace

ologit secondary_local_help age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust


margins,  at(educat=(0(1)5)) atmeans over(country) predict(outcome(2))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(vsmall)) ytitle("Probability for 2 different secondary providers of local support", size(small)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14))  ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) ///
 plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) ///
 ci4opts(lpatter(dash)lcolor(gs12)) ///
 ci6opts(lpatter(dash)lcolor(gs12)) nodraw
graph save secondary_local_help, replace

grc1leg primary_local_help.gph secondary_local_help.gph

reg total_local_help age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust

margins,  at(educat=(0(1)5)) atmeans over(country)

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(vsmall)) ytitle("Probability for 2 different secondary providers of local support", size(small)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14))  ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) ///
 plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) ci6opts(lpatter(dash)lcolor(gs12)) 
graph save total_local_help, replace

// MEASURE 2 FOR LOCAL HELP (HOUSE VS ILLNESS)

ologit local_help_house age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust


margins,  at(educat=(0(1)5)) atmeans over(country) predict(outcome(2))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(vsmall)) ytitle("Probability for 2 different primary providers of local support", size(small)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14)) ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) nodraw
graph save local_help_house, replace


ologit local_help_illness age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [aw=weight_country], cluster(country) robust


margins,  at(educat=(0(1)5)) atmeans over(country) predict(outcome(2))

qui marginsplot, scheme(vg_s1c) xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) xtitle(, size(vsmall)) ytitle("Probability for 2 different secondary providers of local support", size(small)) title("",size(zero)) ///
legend(region(lwidth(none)) bmargin(vsmall) size(vsmall) rows(1) all)   ///
recast(line) recastci(rarea) ciopts(color(gs14))  ///
plot1opts(lcolor(blue) msymbol("circle")) plot2opts(lcolor(midgreen) msymbol(triangle)) plot3opts(lcolor(red) msymbol(diamond)) ///
 plot4opts(lcolor(black) msymbol(smsquare_hollow)) plot5opts(lcolor(purple) msymbol(circle_hollow)) plot6opts(lcolor(orange) msymbol(smplus)) ci6opts(lpatter(dash)lcolor(gs12)) nodraw
graph save local_help_illness, replace

grc1leg local_help_house.gph local_help_illness.gph


}

{ // SUPPLEMENTARY ANALYSES

 // 0-INFLATED POISSON REG FOR NEIGHBORING AS A ROBUSTNESS CHECK:

xi: zip propfrndneighbor age agesquared i.sex i.marital i.location church_attendance degree c.Kfamilyincome##c.Kfamilyincome educat ib4.country [pw=weight_country], inflate(i.educat) cluster(country) robust 
xi: zip propfrndneighbor age agesquared i.sex i.marital i.location church_attendance degree ib4.country##c.Kfamilyincome c.Kfamilyincome#c.Kfamilyincome ib4.country##c.educat [pw=weight_country], inflate(i.educat) cluster(country) robust 



// Thorough descriptive table:

eststo: tabstat distborrow disthelp distadvice distfamhelp propfrndneighbor specialized_strong local_help grand_specialization age church_attendance ///
 Kfamilyincome educat location, by(country) stat(mean sd min max) 
estout using tables.rtf, replace 


foreach i in 1 2 4 5 6 7 {
quietly estpost sum distborrow disthelp distadvice distfamhelp propfrndneighbor specialized_strong local_help grand_specialization age church_attendance ///
 Kfamilyincome educat if country==`i'
est store D`i'
}

esttab D* using Descriptives.rtf, cells( "mean(fmt(2))" "sd(fmt(2) par)") mtitle("Australia" "West Germany" "USA" "Austria" "Hungary" "Italy") ///
label nonum collabels(none) replace title(Descriptives) 

// AS PER REVIEWER 1'S REQUEST: RE-DOING ALL ANALYSES WITHOUT FAMILY INCOME
*********
eststo clear
local depvars "distborrow disthelp distadvice distfamhelp"

foreach dv in `depvars' { 

xi: reg log`dv' age agesquared i.sex i.marital i.location church_attendance degree educat ib4.country [pw=final_weight_miss_`dv'], cluster(country) robust
estimates store tab_log`dv'
}

esttab tab_logdistborrow tab_logdisthelp tab_logdistadvice tab_logdistfamhelp using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_no_income.rtf", ///
 replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 

**********
eststo clear
local depvars "distborrow2 disthelp2 distadvice2 distfamhelp2"

foreach dv in `depvars' { 

xi: reg  log`dv' age agesquared i.sex i.marital i.location church_attendance degree educat ib4.country [pw=final_weight_miss_`dv'], cluster(country) robust
estimates store tab_log`dv'
}

esttab tab_logdistborrow2 tab_logdisthelp2 tab_logdistadvice2 tab_logdistfamhelp2 using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_`dv'_ISS_data_second_alter_no_income.rtf", ///
replace b(3) se (3) r2(3) coeflabels(1b.sex "Male") label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 
************
eststo clear
reg propfrndneighbor age agesquared i.sex i.marital i.location church_attendance degree educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_propfrndneighbor

ologit primary_local_help age agesquared i.sex i.marital i.location church_attendance degree educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_primary_local_help

ologit secondary_local_help age agesquared i.sex i.marital i.location church_attendance degree educat ib4.country [pw=weight_country], cluster(country) robust
estimates store tab_secondary_local_help

esttab tab_propfrndneighbor tab_primary_local_help tab_secondary_local_help using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Neighboring_&_local_help_no_income.rtf", replace b(3) se (3) r2(3) label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001) 




}





}


{ // OTHER STUFF
 
 // THESE ARE RAW COMMANDS TO EXPORT MY TABLES

xi: qui reg specialized_ties age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country [aw=weight_country], cluster(country) robust
estimates store tab_1
xi: qui reg specialized_help2 age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country [aw=weight_country], cluster(country) robust
estimates store tab_2
xi: qui reg grand_specialization age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country [aw=weight_country], cluster(country) robust
estimates store tab_3
xi: qui reg propfrndneighbor age agesquared i.sex i.marital i.location church_attendance c.Kfamilyincome##c.Kfamilyincome educat ib4.country [aw=weight_country], cluster(country) robust
estimates store tab_4


esttab tab_1 tab_2 tab_3 using "/Users/Ldrouhot/Google Drive/Papers/Reconsidering Community Liberated. Inequality and the Social Context of Personal Networks/Other material (tables, figures, etc)/R & R Material/Pooled_country_specialization_ISS_data.rtf", replace se r2 label mtitles starlevels (+ 0.10 * 0.05 ** 0.01 *** 0.001)

// Old commands for getting a margins plot with derivatives calculated manually (in this case, for education:

/**
margins country, at(educat=1) atmeans
mat i=r(b)

margins country, dydx(educat) atmeans
mat s=r(b)

graph twoway (function y = i[1,1]+s[1,1]*x, range(1 5))  ///
             (function y = i[1,2]+s[1,2]*x, range(1 5))  ///
             (function y = i[1,3]+s[1,3]*x, range(1 5))  ///
             (function y = i[1,4]+s[1,4]*x, range(1 5))  ///
             (function y = i[1,5]+s[1,5]*x, range(1 5)) ///
			 (function y = i[1,6]+s[1,6]*x, range(1 5)), ///
             legend(order(1 "Australia" 2 "West Germany"        ///
             3 "USA" 4 "Austria" 5 "Hungary" 6 "Italy"))      ///
             xtitle("Education") ytitle("`dv'")       ///
             title("") xmtick(##10) ymtick(##10) xlabel(,labs(vsmall)) ylabel(,labs(vsmall)) name(reg_`dv', replace) legend(off)
*/

*esttab tab_`dv' tab_UK_`dv' using "/Users/Ldrouhot/Google Drive/Spring 2015/Reconsidering Community Liberated; Inequality and the Social Context of Personal Networks/Network Localism/Interactions_Pooled_country_`dv'_ISS_data.rtf", replace se r2 label mtitles noconstant

gen urb_country=.
replace urb_country=1 if location==1 & country==1
replace urb_country=2 if location==2 & country==1
replace urb_country=3 if location==3 & country==1
replace urb_country=4 if location==1 & country==2
replace urb_country=5 if location==2 & country==2
replace urb_country=6 if location==3 & country==2
replace urb_country=7 if location==1 & country==4
replace urb_country=8 if location==2 & country==4
replace urb_country=9 if location==3 & country==4
replace urb_country=10 if location==1 & country==5
replace urb_country=11 if location==2 & country==5
replace urb_country=12 if location==3 & country==5
replace urb_country=13 if location==1 & country==6
replace urb_country=14 if location==2 & country==6
replace urb_country=15 if location==3 & country==6
replace urb_country=16 if location==1 & country==7
replace urb_country=17 if location==2 & country==7
replace urb_country=18 if location==3 & country==7

label define urb_country1 1 "AUS URB" 2 "AUS SEM" 3 "AUS RUR" 4 "WG URB" 5 "WG SEM" 6 "WG RUR" 7 "US URB" 8 "US SEM" ///
9 "US RUR" 10 "OST URB" 11 "OST SEM" 12 "OST RUR" 13 "ITA URB" 14 "ITA SEM" 15 "ITA RUR" 16 "HUN URB" 17 "HUN SEM" 18 "HUN RUR"

label values urb_country urb_country1

by urb_country, sort: egen mean_distborrow=mean(distborrow)
by urb_country, sort: egen sd_distborrow=sd(distborrow)
gen ub=mean_distborrow+sd_distborrow
gen lb=mean_distborrow-sd_distborrow

graph dot lb mean_distborrow ub, over(urb_country) legend(region(sty(legend))) legend(label(1 "-1sd")) ///
legend(label(2 "Mean")) legend(label(3 "+1sd")) title("Distance to material support by country and urbanism, in hours") ///
note("Source: 1986 ISS data") ymtick(##10)  ytitle("Hours") label 

by urb_country, sort: egen mean_distadvice=mean(distadvice)
by urb_country, sort: egen sd_distadvice=sd(distadvice)
gen ub1=mean_distadvice+sd_distadvice
gen lb1=mean_distadvice-sd_distadvice

graph dot lb1 mean_distadvice ub1, over(urb_country) legend(region(sty(legend))) legend(label(1 "-1sd")) ///
legend(label(2 "Mean")) legend(label(3 "+1sd")) title("Distance to advisor by country and urbanism, in hours") ///
note("Source: 1986 ISS data") ymtick(##10)  ytitle("Hours") label 

by urb_country, sort: egen mean_disthelp=mean(disthelp)
by urb_country, sort: egen sd_disthelp=sd(disthelp)
gen ub2=mean_disthelp+sd_disthelp
gen lb2=mean_disthelp-sd_disthelp

graph dot lb2 mean_disthelp ub2, over(urb_country) legend(region(sty(legend))) legend(label(1 "-1sd")) ///
legend(label(2 "Mean")) legend(label(3 "+1sd")) title("Distance to mental support by country and urbanism, in hours") ///
note("Source: 1986 ISS data") ymtick(##10)  ytitle("Hours") label 


by urb_country, sort: egen mean_propfrndneighbor=mean(propfrndneighbor)
by urb_country, sort: egen sd_propfrndneighbor=sd(propfrndneighbor)
gen ub3=mean_propfrndneighbor+sd_propfrndneighbor
gen lb3=mean_propfrndneighbor-sd_propfrndneighbor

graph dot lb3 mean_propfrndneighbor ub3, over(urb_country) legend(region(sty(legend))) legend(label(1 "-1sd")) ///
legend(label(2 "Mean")) legend(label(3 "+1sd")) title("% neighbors among close friends by country and urbanism, in hours") ///
note("Source: 1986 ISS data") ymtick(##10)  ytitle("Hours") label 


}

 
