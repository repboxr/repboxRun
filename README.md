# repboxRun

Repbox package that contains functions to run all or specific analyses of a supplements.

## Stuff that does not work

Repbox will not be able to replicate all things even if data is not missing. But we aim to replicate a large percentage of reproduction packages / articles. Here are examples of constructions that do not work.

### A do file is run multiple times

aejmic_11_3_10: does call a particular do file multiple times instead defining a program that will then be called multiple times. This cannot be properly handled by repbox so far.

### Regressions use chained time series operators

aejmac_12_3_10: Has the regressions

eststo: reg s2.lCF EMILIA `controlli' l2.s2.lCF if OO==1 & INDEXLIQ==1, r

We cannot deal with the chained operator `l2.s2` in `l2.s2.lCF`.

### Regression using range time series prefixes

We do not yet deal with time series prefixes like
L(0/4).x1

### Inline for loops

aejpol_7_2_11:

xi: for var Dgender no_tickets no_ticketorder avevalue_tickets value_tickets postcode_munich Dyear_firstentry: reg X i.match1_control if match_treat==1|match_treat==`i', robust;


The values `X` in the regression takes the values specified in the for statement before the :.
It is unlikely, that we will successfully be able to parse regression results from such constructions, since we cannot inject code in an inline for loop.
