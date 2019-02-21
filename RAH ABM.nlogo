globals [ preventabledeathcount
  naturaldeathcount]


breed [ SAPops SAPop ]
breed [ AcuteCares AcuteCare ]
breed [ GPs GP ]
breed [ NewPatients NewPatient ]
breed [ PreventableDeaths PreventableDeath ]
breed [ ReviewPatients ReviewPatient ]
breed [ Deathpools Death ]
breed [ DNAPool1s DNAPool1 ]
breed [ DNAPool2s DNAPool2 ]
breed [ SpecialistOutPatientServices SpecialistOutPatientsService ]
breed [ UntreatedPopulations UntreatedPopulation ]
breed [ Specialists Specialist ]
breed [ Waitlists waitlist ]
breed [ Patients Patient ]

Patients-own ; states and qualities that individual patients have or are in at any stage
[
  motivation
  InGP
  InAcuteCare
  InPreventableDeaths
  InNewPatients
  InReviewPatients
  InDeath
  InUntreatedPopulation
  InDNAPool1
  InDNAPool2
  InWaitlist
  State1
  GoingtoGP
  GoingtoAcuteCare
  GoingtoPreventableDeath
  GoingtoNewPatient
  GoingtoReviewPatient
  GoingtoDeath
  GoingtoUntreatedPopulation
  GoingtoDNAPool1
  GoingtoDNAPool2
  GoingtoWaitlist
  GoingtoSAPops
  Trust
  Memory
  Health
  Satisfaction
]

to setup
  clear-all
  create-GPs 1 [ set shape "box" set size 5 set label "GP" set xcor 13.92 set ycor 42.25 set color red]
  create-AcuteCares 1 [ set shape "box" set size 5 set label "Acute Care" set xcor 6.35 set ycor 33.52 set color green ]
  create-Waitlists 1 [ set shape "box" set size 5 set label "Waitlist" set xcor 4.71 set ycor 22.1 set color orange ]
  create-newPatients 1 [ set shape "box" set size 5 set label "New Patients" set xcor 9.51 set ycor 11.58 set color yellow ]
  create-Preventabledeaths 1 [ set shape "x"  set size 5 set label "Preventable Deaths" set xcor 19.22 set ycor 5.33 set color white]
  create-ReviewPatients 1 [ set shape "box"  set size 5 set label "Review Patients" set xcor 30.77 set ycor 5.33 set color blue ]
  create-DeathPools 1 [ set shape "x"  set size 5 set label "Natural Deaths" set xcor 40.49 set ycor 11.58 set color blue - 10]
  create-DNAPool1s 1 [ set shape "box" set size 5 set label "First DNA" set xcor 45.29 set ycor 22.08 set color green - 10 ]
  create-DNAPool2s 1 [ set shape "box" set size 5 set label "Second DNA" set xcor 43.65 set ycor 33.52 set color red - 10 ]
  create-UntreatedPopulations 1 [ set shape "box" set size 5 set label "Untreated Population" set xcor 36.08 set ycor 42.25 set color yellow - 10 ]
  create-SAPops 1 [ set shape "circle 2" set xcor 25 set ycor 25 set size 5 set label "General Population" set xcor 25 set ycor 45.5 set color white + 10 ]
  ask turtles [ create-links-with other turtles show label ]
  create-patients Population [ set shape "dot" set state1 0 move-to one-of SAPops set color white ]
  create-Specialists (100 - New_to_Review_Barrier) [ set shape "person" setxy random-xcor random-ycor set color green ]
  create-SpecialistOutPatientServices SOSCapacity [ set shape "person" setxy random-xcor random-ycor set color blue  ]
  reset-ticks
end

to go
  ask patients [
    initialise
    gpreferral
    emergency
    deathincare
    becomenew
    becomeReview
    becomeDNA1
    becomeDNA2
    DNA2decisions
    becomePreventableDeath
    UntreatedReEnter
    BecomeReviewfromDNA
    becomeWaitlist
    NewtoGeneral
    DNAFromGP

  ]
  ask turtles [
    set size (5 + sqrt count patients in-radius 1 )
      ]
  ask patients [ set size 1 ]
  ask specialists [ set size 1 fd 1 face one-of NewPatients if any? NewPatients in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ] ]
  ask SpecialistOutPatientServices [ set size 1 fd 1 ]
  ask SpecialistOutPatientServices [ if focus = "GPs" [ face one-of GPs if any? GPs in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]
  ] if focus = "Waitlist" [ face one-of Waitlists if any? Waitlists in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "DNA 1" [ face one-of DNAPool1s if any? DNAPool1s in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "DNA 2" [ face one-of DNAPool2s if any? DNAPool2s in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "Review Patients" [ face one-of ReviewPatients if any? ReviewPatients in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "New Patients" [ face one-of NewPatients if any? NewPatients in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "Acute Care" [ face one-of AcuteCares if any? AcuteCares in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]
  if focus = "General Population" [ face one-of SAPops if any? SAPops in-radius random 5 [ set heading heading + random 5 - random 5 fd 5 ]]


  ]

  if count patients < 500 [ create-patients New_Patients  [ set shape "dot" set state1 0 move-to one-of SAPops set color white ] ]

  countpreventabledeaths
  growSOS
  GrowClinicalCapacity
 ;; burnpatches
  if ticks = 10000 [ stop ]
  tick
end

to initialise
  set state1 1
end

to gpreferral ;; individuals emerging from the general population into GPs
  if GP_referral_barrier < random 100 and state1 = 1 and any? SAPops-here  [
    face one-of GPs fd random-normal 1 .1 set goingtoGP 1 ]
     if goingtoGP = 1 [ face one-of GPs fd random-normal 1 .1 ]
       if any? GPs in-radius 1 [ move-to one-of GPs set InGP 1 set goingtoGP 0 set state1 0 ]
end

to emergency ;; individuals emerging from the general population into emergency areas of hospitals
    if Emergency_Pres < random 100 and state1 = 1 and InAcuteCare = 0 and any? SAPops-here [
      face one-of AcuteCares fd random-normal 1 .1  set GoingtoAcuteCare 1 ]
       if GoingtoAcuteCare = 1 [ face one-of AcuteCares fd random-normal 1 .1 ]
        if any? AcuteCares in-radius 1 [ move-to one-of AcuteCares set InAcuteCare 1 set InGP 0 set GoingtoAcuteCare 0 ]
end

to becomeWaitlist ;;
     if Acute_Care_Barrier < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
      face one-of Waitlists fd random-normal 1 .1  set goingtoWaitlist 1 ]
    if goingtoWaitlist = 1 [ Face one-of Waitlists fd random-normal 1 .1 ]
        if any? Waitlists in-radius 1 [ move-to one-of Waitlists Set InWaitlist 1 set InAcuteCare 0 set GoingtoWaitlist 0  ]

    if GP_Referral_Barrier < random 100 and InGP = 1 and any? GPs-here [
      face one-of Waitlists fd random-normal 1 .1  set goingtoWaitlist 1 ]
    if goingtoWaitlist = 1 [ Face one-of Waitlists fd random-normal 1 .1 ]
        if any? Waitlists in-radius 1 [ move-to one-of Waitlists Set InWaitlist 1 set InGP 0 set GoingtoWaitlist 0  ]
end

to becomeNew
     if Waitlist_Delay < random 100 and InWaitlist = 1 and any? Waitlists-here [
      face one-of NewPatients fd random-normal 1 .1  set goingtoNewPatient 1 ]
    if goingtoNewPatient = 1 [ Face one-of NewPatients fd random-normal 1 .1 ]
        if any? NewPatients in-radius 1 [ move-to one-of NewPatients Set InNewPatients 1 set InWaitlist 0 set GoingtoNewPatient 0  ]
end

to becomeReview
    if New_to_Review_Barrier < random 100 and InNewPatients = 1 and any? NewPatients-here [
      face one-of ReviewPatients fd random-normal 1 .1  set GoingtoReviewPatient 1 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd random-normal 1 .1  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InNewPatients 0 set GoingtoreviewPatient 0 ]

if Acute_to_Review < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
      face one-of ReviewPatients fd random-normal 1 .1  set GoingtoReviewPatient 1 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd random-normal 1 .1  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InNewPatients 0 set GoingtoreviewPatient 0 ]

end

to becomeDNA1
   if DNA1_Rate > random 100 and InReviewPatients = 1 and any? ReviewPatients-here and not any? SpecialistoutpatientServices in-radius 2 [
     face one-of DNAPool1s fd random-normal 1 .1  set GoingtoDNAPool1 1 ]
     if GoingtoDNAPool1 = 1 [ face one-of DNAPool1s fd random-normal 1 .1 ]
    if any? DNAPool1s in-radius 1 [ move-to one-of DNAPool1s Set InDNAPool1 1 set InReviewPatients 0 set GoingtoDNAPool1 0 ]

end

to DNAFromGP
  if DNA_from_GP_Rate > random 100 and InGP = 1 and any? GPs-here [
     face one-of DNAPool1s fd random-normal 1 .1  set GoingtoDNAPool1 1 ]
     if GoingtoDNAPool1 = 1 [ face one-of DNAPool1s fd random-normal 1 .1 ]
    if any? DNAPool1s in-radius 1 [ move-to one-of DNAPool1s Set InDNAPool1 1 set InGP 0 set GoingtoDNAPool1 0 ]
end

to becomeDNA2
     if DNA2_Rate > random 100 and InDNAPool1 = 1 and any? DNAPool1s-here and not any? SpecialistoutpatientServices in-radius 2 [
     face one-of DNAPool2s fd random-normal 1 .1  set GoingtoDNAPool2 1 ]
     if GoingtoDNAPool2 = 1 [ face one-of DNAPool2s fd random-normal 1 .1 ]
    if any? DNAPool2s in-radius 1 [ move-to one-of DNAPool2s Set InDNAPool2 1 set InDNAPool1 0 set GoingtoDNAPool2 0 ]
end

to BecomeReviewfromDNA

if DNA1_to_Review_Rate > random 100 and InDNAPool1 = 1 and any? DNAPool1s-here [
      face one-of ReviewPatients fd random-normal 1 .1  set GoingtoReviewPatient 1 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd random-normal 1 .1  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InDNAPool1 0 set GoingtoreviewPatient 0 ]

if DNA2_to_Review_Rate > random 100 and InDNAPool2 = 1 and any? DNAPool2s-here [
      face one-of ReviewPatients fd random-normal 1 .1  set GoingtoReviewPatient 1 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd random-normal 1 .1  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InDNAPool2 0 set GoingtoreviewPatient 0 ]
end

to DNA2Decisions
    if Active_Discharge_Rate > random 100 and InDNAPool2 = 1 and any? DNAPool2s-here [
     face one-of UntreatedPopulations fd random-normal 1 .1  set GoingtoUntreatedPopulation 1 Set InDNAPool2 0 ]
     if GoingtoUntreatedPopulation = 1 [ face one-of UntreatedPopulations fd random-normal 1 .1 ]
    if any? UntreatedPopulations in-radius 1 [ move-to one-of UntreatedPopulations Set InDNAPool2 0 set InUntreatedPopulation 1 set GoingtoUntreatedPopulation 0 ]
end

to deathincare
   if 60 < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
     face one-of Deathpools fd random-normal 1 .1  set GoingtoDeath 1 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd random-normal 1 .1  ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InAcutecare 0 ]

 if Death_Rate_Review > random 100 and InReviewPatients = 1 and any? ReviewPatients-here  [
     face one-of Deathpools fd random-normal 1 .1  set GoingtoDeath 1 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd random-normal 1 .1 ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InReviewPatients 0 ]

 if Death_Rate_Waitlist > random 100 and Inwaitlist = 1 and any? Waitlists-here [
    face one-of Deathpools fd random-normal 1 .1  set GoingtoDeath 1 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd random-normal 1 .1  ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InWaitlist 0 ]

end

to becomePreventableDeath
  if Death_Rate_Untreated > random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of PreventableDeaths fd random-normal 1 .1  set GoingtoPreventableDeath 1 ]
   if GoingtoPreventableDeath = 1 [ face one-of PreventableDeaths fd random-normal 1 .1 ]
    if any? PreventableDeaths in-radius 1 [ move-to one-of PreventableDeaths set InPreventableDeaths 1 die ]
end

to countpreventabledeaths
  set preventabledeathcount ( count patients with [ goingtopreventabledeath = 1 ] )
  set naturaldeathcount ( count patients with [ GoingtoDeath = 1 ] )

end

to UntreatedReEnter
  if Return_to_General > random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of SAPops fd random-normal 1 .1  set GoingtoSAPops 1 ]
   if GoingtoSAPops = 1 [ face one-of SAPops fd random-normal 1 .1 ]
    if any? SAPops in-radius 1 [ move-to one-of SAPops set State1 1 set GoingtoSAPops 0 ]

if Return_to_General < random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of ReviewPatients fd random-normal 1 .1  set GoingtoReviewPatient 1 ]
   if GoingtoReviewPatient = 1 [ face one-of ReviewPatients fd random-normal 1 .1 ]
    if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients set State1 1 set GoingtoReviewPatient 0 ]

end

to NewtoGeneral
  if 20 > random 100 and InNewpatients = 1 and any? newPatients-here [ ;; Patients move from being New back into the General Population
     face one-of SAPops fd random-normal 1 .1  set GoingtoSAPops 1 ]
  if GoingtoSAPops = 1 [ face one-of SAPops fd random-normal 1 .1 ]
    if any? SAPops in-radius 1 [ move-to one-of SAPops set State1 1 set GoingtoSAPops 0 set InNewPatients 0 ]
end

to burnpatches
  ask patches [
    if any? patients-here [ set pcolor pcolor + .01 ]
  ]
end

to GrowSOS
  if count SpecialistOutpatientServices <= SOSCapacity [ ask one-of SpecialistOutpatientServices [ hatch 1 ] ]
  if count SpecialistOutpatientServices > SOSCapacity [ ask one-of SpecialistOutpatientServices [ die ] ]
end

to GrowClinicalCapacity
  if count Specialists <= ( 101 - New_to_Review_Barrier ) [ ask one-of Specialists [ hatch 1 fd random .1 ]  ]
  if count Specialists > ( 101 - New_to_Review_Barrier ) [ ask one-of Specialists [ die ] ]
end
@#$#@#$#@
GRAPHICS-WINDOW
315
10
866
562
-1
-1
10.65
1
10
1
1
1
0
0
0
1
0
50
0
50
1
1
1
ticks
30.0

BUTTON
10
10
75
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
50
75
83
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1208
352
1315
397
Total Patients
count Patients * 10
0
1
11

SLIDER
80
10
185
43
Population
Population
0
500
80.0
10
1
NIL
HORIZONTAL

MONITOR
1208
401
1274
446
With GP
count Patients with [ inGP = 1 ] * 10
0
1
11

PLOT
878
11
1641
347
Patient States
Time
Amount
0.0
3.0
0.0
10.0
true
true
"" "if ticks = 100 [ clear-plot ] \n\nif remainder ticks 3001 =  0 [ clear-plot ]  \n\nif \"Reset Patients\" = true [ clear-plot ] "
PENS
"New Patients" 1.0 0 -11085214 true "" "plot count patients with [ inNewPatients = 1 ] "
"Review Patients" 1.0 0 -14454117 true "" "plot count patients with [ inreviewPatients = 1 ] "
"With GP" 1.0 0 -2674135 true "" "plot count patients with [ InGP = 1 ] "
"In Waitlist" 1.0 0 -955883 true "" "plot count patients with [ inWaitlist = 1 ] "

MONITOR
1338
401
1429
446
New Patients
count patients with [InNewPatients = 1] * 10
0
1
11

MONITOR
1319
352
1429
397
Review Patients
count patients with [Inreviewpatients = 1 ] * 10
0
1
11

BUTTON
196
12
308
45
Reset Patients
ask patients [ die ] \nask turtles [ set size 5 ] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
197
48
308
81
Trace Paths
ask patients [ pen-down ] 
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
878
352
1203
573
DNA States
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" "if remainder ticks 3000 =  0 [ clear-plot ]  \n\n;;if \"Reset patients\" = true [ clear-plot ] "
PENS
"DNA Pool 1 " 1.0 0 -16777216 true "" "plot count patients with [ InDNAPool1 = 1 ] "
"DNA Pool 2 " 1.0 0 -7500403 true "" "plot count patients with [ InDNAPool2 = 1 ] "
"Total DNA Costs" 1.0 0 -2674135 true "" "plot count patients with [ InDNAPool1 = 1 ] + count patients with [ InDNAPool2 = 1 ] "

PLOT
1210
452
1641
572
Deaths
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" "if ticks = 100 [ clear-plot ] \nif remainder ticks 3001 =  0 [ clear-plot ]  \n\n;; if \"Reset Patients\" = true [ clear-plot ] "
PENS
"Preventable Deaths" 1.0 0 -14070903 true "" "plot preventabledeathcount"
"Natural Deaths" 1.0 0 -2674135 true "" "plot naturaldeathcount"

SLIDER
19
127
145
160
GP_Referral_Barrier
GP_Referral_Barrier
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
20
160
145
193
Waitlist_Delay
Waitlist_Delay
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
148
128
280
161
Acute_Care_Barrier
Acute_Care_Barrier
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
62
509
239
542
New_to_Review_Barrier
New_to_Review_Barrier
1
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
59
272
239
305
DNA1_to_Review_Rate
DNA1_to_Review_Rate
0
100
79.0
1
1
NIL
HORIZONTAL

SLIDER
59
307
238
340
DNA2_to_Review_Rate
DNA2_to_Review_Rate
0
100
66.0
1
1
NIL
HORIZONTAL

SLIDER
325
612
456
645
DNA1_Rate
DNA1_Rate
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
325
647
457
680
DNA2_Rate
DNA2_Rate
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
60
342
239
375
Death_Rate_Untreated
Death_Rate_Untreated
0
100
9.0
1
1
NIL
HORIZONTAL

SLIDER
61
376
238
409
Death_Rate_Waitlist
Death_Rate_Waitlist
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
61
410
239
443
Active_Discharge_Rate
Active_Discharge_Rate
0
100
62.0
1
1
NIL
HORIZONTAL

CHOOSER
81
48
189
93
New_Patients
New_Patients
1 2 3 4 5
4

SLIDER
61
443
239
476
Death_Rate_Review
Death_Rate_Review
0
100
6.0
1
1
NIL
HORIZONTAL

MONITOR
1278
401
1335
446
Waitlist
count patients with [ inwaitlist = 1 ] * 10
0
1
11

SLIDER
62
477
238
510
Return_to_General
Return_to_General
0
100
20.0
1
1
NIL
HORIZONTAL

TEXTBOX
325
577
475
605
Rate at which patients DNA\nat each level
11
0.0
1

MONITOR
1433
352
1510
397
DNA Total
( count patients with [ InDNAPool1 = 1 ] +\ncount patients with [ InDNAPool2 = 1 ] ) * 10
0
1
11

SLIDER
148
162
280
195
SOSCapacity
SOSCapacity
1
100
34.0
1
1
NIL
HORIZONTAL

CHOOSER
70
206
222
251
Focus
Focus
"GPs" "Waitlist" "New Patients" "Review Patients" "DNA 1" "DNA 2" "Acute Care" "General Population"
3

MONITOR
1435
401
1510
446
Staff Costs
( count SpecialistOutPatientServices + count Specialists ) * 1000000
0
1
11

SLIDER
62
545
238
578
Emergency_Pres
Emergency_Pres
0
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
62
580
238
613
Acute_to_Review
Acute_to_Review
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
63
619
238
652
DNA_From_GP_Rate
DNA_From_GP_Rate
0
100
41.0
1
1
NIL
HORIZONTAL

BUTTON
520
571
666
604
System Performance
ask patches [ set pcolor black ] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model simulates points of information and/or resource exchange in an urban environment. An urban environment is assumed to be a pedestrian friendly city-space where people normally encounter one another on a face-to-face basis; and, typically encounter informational systems (such as advertising) and exchange systems (such as consumer based shopping).

The object of the model is to simulate people's awareness of the value of exchanging resources, and evaluate the influence "aware" people have on one another, and on their environment in an information-rich context such as a city.

## HOW IT WORKS

The model determines a person's theoretical level of "awareness" within an urban environment based upon a person's random encounter with information centers. In the model, information centers are any source of positive information exchange such as an advertisement (for a public good) or a recycling center. In general terms, "awareness" involves a person showing realization, perception, or knowledge.

In this model, each person has some amount of "awareness", which is measured in "awareness points".  There is a discrete set of "levels" of awareness that people may attain.  A person may be "unaware" (0 - 5 points), "aware" (5 - 10 points), "well-informed" (10 - 15 points), or an "activist" (more than 15 points).

To gain awareness, a person either runs into a center, where they gain five awareness points; or is influenced by a person who is well-informed or an activist, where they gain one awareness point. If one of these events does not occur during a given time step (tick), the person will lose one awareness point (down to zero).  In this model, there is no such thing as "negative awareness".

(The idea of negative awareness may sound ridiculous, but it could make sense in some situations -- for instance, if some faction is spreading information that is in direct conflict to another faction, and people may come into contact with information and advertising promoting either position.  That is, negative awareness might represent "subscription to an opposing and irreconcilable viewpoint".  For instance, in the United States, there are activists working both for and against the legality of abortion.)

When a person becomes an activist (15 awareness points), a new center is formed.  The new information centers are colored blue, whereas the initial information centers are green.

If no one comes into contact with a center for a specified amount of time (see the NON-USAGE-LIMIT slider), the center disappears from the world.  The intuition here is that if an information/advertising method or location is yielding no fruit, eventually it will be shut down.

## HOW TO USE IT

Press SETUP and then GO.

The PEOPLE slider determines how many people "agents" are randomly distributed in the initial setup phase of the model

The CENTERS slider determines how many information centers are randomly distributed in the initial setup of the model.

The NON-USAGE-LIMIT determines how many ticks a center can go unused before being shut down.

Use the PLACE-CENTERS button to manually place information centers on the view (by clicking their locations with the mouse, while the PLACE-CENTERS button is turned on).

There are also numerous monitors that display information about the current state of the world, such as the current breakdown of awareness in the population, via the ACTIVIST, "WELL INFORMED", AWARE, and UNAWARE monitors.

The CENTERS monitor tells how many information centers are present in the world.

The AVG. NON-USAGE monitor tells the average number of ticks it has been since each of the information centers has been used (i.e. influenced a person).

The AVERAGE STATE OF AWARENESS monitor tells the average number of awareness points that people in the population have.

The LEVELS OF AWARENESS plot shows the history of how many people were at each level of awareness at each tick of the model, and the AVG. AWARENESS plot keeps track of the average awareness of the population over time.

## THINGS TO NOTICE

The initial relative density of people to centers is vital to achieving systemic balance. The model simulates a complex system of data exchange by exploring positive feedback; and the model was created as a lens to describe one important process of emergent pattern formation in a sustainable city.  Specifically, the model allows us to study and discuss the important relationship between a population and its ability to learn and become participatory in the building of its own environment. Here are some questions to encourage discussion about the model and the topics it broaches.

Is there a minimum number of people or centers needed to eventually make everyone an activist?  Does it happen suddenly or gradually?  You can see this both visually, and it is represented in both the LEVELS OF AWARENESS plot, and the AVG. AWARENESS plot.

Where do new information centers tend to form?

What if you only look at the number of "aware" or "well-informed" people over time -- what does that plot look like?  Can you explain its shape?

## THINGS TO TRY

Run the model with 200 PEOPLE, 50 CENTERS, and 100 ticks for the NON-USAGE-LIMIT.  Now try decreasing the NON-USAGE-LIMIT slider.  How low can you go before global awareness isn't achieved?  Does it help to raise the initial number of people or centers?

Try manually placing 20 centers (using the PLACE-CENTERS button) spread out across the world, and run the model.  Now try manually placing just 5 centers, but in a tight cluster.  What are the results?  Do you think this result is realistic, or is indicative of a faulty model of how awareness and activism occurs?

## EXTENDING THE MODEL

Try changing the model so that it simulates two competing and opposed viewpoints (such as legalizing marijuana, or perhaps something more broad, such as Republican versus Democrat politics).  Do this by allowing negative awareness, and have people with less than -15 awareness points be anti-activists, etc.

What if there were more than two opposing points of view?

## NETLOGO FEATURES

It is very common in agent-based models to initialize the setup of the model by positioning agents randomly in the world.  NetLogo makes it easy to move an agent to a random location, with the following code: "SETXY RANDOM-XCOR RANDOM-YCOR".

## RELATED MODELS

This model is related to all of the other models in the "Urban Suite".

This model is also similar to the Rumor Mill model, which is found in the NetLogo models library.

## CREDITS AND REFERENCES

The original version of this model was developed during the Sprawl/Swarm Class at Illinois Institute of Technology in Fall 2006 under the supervision of Sarah Dunn and Martin Felsen, by the following students: Eileen Pedersen, Brian Reif, and Susana Odriozola.  See http://www.sprawlcity.us/ for more information about this course.

Further modifications and refinements were made by members of the Center for Connected Learning and Computer-Based Modeling before releasing it as an Urban Suite model.

The Urban Suite models were developed as part of the Procedural Modeling of Cities project, under the sponsorship of NSF ITR award 0326542, Electronic Arts & Maxis.

Please see the project web site ( http://ccl.northwestern.edu/cities/ ) for more information.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Felsen, M. and Wilensky, U. (2007).  NetLogo Urban Suite - Awareness model.  http://ccl.northwestern.edu/netlogo/models/UrbanSuite-Awareness.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2007 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2007 Cite: Felsen, M. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
